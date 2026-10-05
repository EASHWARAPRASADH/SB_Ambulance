import 'package:noble_pasteur/core/services/location_service.dart';
import 'package:noble_pasteur/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:noble_pasteur/features/profile/domain/repositories/profile_repository.dart';
import 'package:noble_pasteur/features/sos/domain/entities/sos_dispatch.dart';
import 'package:noble_pasteur/features/sos/domain/repositories/sos_repository.dart';

class TriggerSosUseCase {
  final LocationService _locationService;
  final HospitalRepository _hospitalRepository;
  final ProfileRepository _profileRepository;
  final SosRepository _sosRepository;

  TriggerSosUseCase(
    this._locationService,
    this._hospitalRepository,
    this._profileRepository,
    this._sosRepository,
  );

  Future<SosDispatch> execute() async {
    // 1. Get high-precision GPS position
    final position = await _locationService.getCurrentLocation();

    // 2. Locate nearest hospital
    final hospital = await _hospitalRepository.getNearestHospital(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    // 3. Retrieve user profile
    final profile = await _profileRepository.getProfile();

    // 4. Dispatch emergency payload
    return await _sosRepository.dispatchAmbulance(
      position: position,
      hospital: hospital,
      profile: profile,
    );
  }
}
