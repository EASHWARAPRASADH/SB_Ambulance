import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_pasteur/core/errors/exceptions.dart';
import 'package:noble_pasteur/core/services/haptic_service.dart';
import 'package:noble_pasteur/core/services/location_service.dart';
import 'package:noble_pasteur/features/hospital/data/datasources/hospital_remote_data_source.dart';
import 'package:noble_pasteur/features/hospital/data/repositories/hospital_repository_impl.dart';
import 'package:noble_pasteur/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:noble_pasteur/features/profile/domain/repositories/profile_repository.dart';
import 'package:noble_pasteur/features/profile/presentation/providers/profile_provider.dart';
import 'package:noble_pasteur/features/sos/data/datasources/sos_remote_data_source.dart';
import 'package:noble_pasteur/features/sos/data/repositories/sos_repository_impl.dart';
import 'package:noble_pasteur/features/sos/domain/repositories/sos_repository.dart';
import 'package:noble_pasteur/features/sos/domain/usecases/trigger_sos_usecase.dart';
import 'sos_state.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final hospitalRemoteDataSourceProvider =
    Provider<HospitalRemoteDataSource>((ref) {
  return HospitalRemoteDataSourceImpl();
});

final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  final remoteDs = ref.watch(hospitalRemoteDataSourceProvider);
  return HospitalRepositoryImpl(remoteDs);
});

final sosRemoteDataSourceProvider = Provider<SosRemoteDataSource>((ref) {
  return SosRemoteDataSourceImpl();
});

final sosRepositoryProvider = Provider<SosRepository>((ref) {
  final remoteDs = ref.watch(sosRemoteDataSourceProvider);
  return SosRepositoryImpl(remoteDs);
});

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});

final triggerSosUseCaseProvider = Provider<TriggerSosUseCase>((ref) {
  return TriggerSosUseCase(
    ref.watch(locationServiceProvider),
    ref.watch(hospitalRepositoryProvider),
    ref.watch(profileRepositoryProvider),
    ref.watch(sosRepositoryProvider),
  );
});

class SosNotifier extends StateNotifier<SosState> {
  final LocationService _locationService;
  final HospitalRepository _hospitalRepository;
  final ProfileRepository _profileRepository;
  final SosRepository _sosRepository;
  final HapticService _hapticService;

  SosNotifier(
    this._locationService,
    this._hospitalRepository,
    this._profileRepository,
    this._sosRepository,
    this._hapticService,
  ) : super(const SosState());

  void onHoldStart() {
    if (state.status == SosStatus.idle) {
      _hapticService.touchDown();
      state = state.copyWith(status: SosStatus.holding, holdProgress: 0.0);
    }
  }

  void updateHoldProgress(double progress) {
    if (state.status == SosStatus.idle || state.status == SosStatus.holding) {
      final clamped = progress.clamp(0.0, 1.0);
      state = state.copyWith(
        status: clamped > 0 ? SosStatus.holding : SosStatus.idle,
        holdProgress: clamped,
      );

      if (clamped >= 1.0) {
        triggerEmergencySequence();
      }
    }
  }

  void onHoldCancelled() {
    if (state.status == SosStatus.holding) {
      state = state.copyWith(status: SosStatus.idle, holdProgress: 0.0);
    }
  }

  Future<void> triggerEmergencySequence() async {
    await _hapticService.triggerConfirmed();

    state = state.copyWith(
      status: SosStatus.locating,
      holdProgress: 1.0,
      errorMessage: null,
      isPermissionPermanentlyDenied: false,
    );

    try {
      // Step 1: GPS Fix
      final position = await _locationService.getCurrentLocation();
      state = state.copyWith(
        status: SosStatus.findingHospital,
        position: position,
      );

      // Step 2: Nearest Hospital lookup
      final hospital = await _hospitalRepository.getNearestHospital(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      state = state.copyWith(
        status: SosStatus.dispatching,
        hospital: hospital,
      );

      // Step 3: Patient profile fetch
      final profile = await _profileRepository.getProfile();

      // Step 4: Dispatch payload
      final dispatch = await _sosRepository.dispatchAmbulance(
        position: position,
        hospital: hospital,
        profile: profile,
      );

      await _hapticService.successPattern();
      state = state.copyWith(
        status: SosStatus.active,
        dispatch: dispatch,
      );
    } on LocationPermissionPermanentlyDeniedException catch (e) {
      await _hapticService.failurePattern();
      state = state.copyWith(
        status: SosStatus.failure,
        errorMessage: e.message,
        isPermissionPermanentlyDenied: true,
      );
    } on AppException catch (e) {
      await _hapticService.failurePattern();
      state = state.copyWith(
        status: SosStatus.failure,
        errorMessage: e.message,
      );
    } catch (e) {
      await _hapticService.failurePattern();
      state = state.copyWith(
        status: SosStatus.failure,
        errorMessage: 'An unexpected emergency dispatch error occurred: $e',
      );
    }
  }

  Future<void> cancelDispatch() async {
    final dispatchId = state.dispatch?.id;
    if (dispatchId != null) {
      try {
        await _sosRepository.cancelDispatch(dispatchId);
      } catch (_) {}
    }
    state = const SosState();
  }

  void resetToIdle() {
    state = const SosState();
  }
}

final sosProvider = StateNotifierProvider<SosNotifier, SosState>((ref) {
  return SosNotifier(
    ref.watch(locationServiceProvider),
    ref.watch(hospitalRepositoryProvider),
    ref.watch(profileRepositoryProvider),
    ref.watch(sosRepositoryProvider),
    ref.watch(hapticServiceProvider),
  );
});
