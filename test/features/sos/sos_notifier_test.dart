import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:noble_pasteur/core/services/haptic_service.dart';
import 'package:noble_pasteur/core/services/location_service.dart';
import 'package:noble_pasteur/features/hospital/domain/entities/hospital.dart';
import 'package:noble_pasteur/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:noble_pasteur/features/profile/domain/entities/user_profile.dart';
import 'package:noble_pasteur/features/profile/domain/repositories/profile_repository.dart';
import 'package:noble_pasteur/features/sos/domain/entities/sos_dispatch.dart';
import 'package:noble_pasteur/features/sos/domain/repositories/sos_repository.dart';
import 'package:noble_pasteur/features/sos/presentation/providers/sos_provider.dart';
import 'package:noble_pasteur/features/sos/presentation/providers/sos_state.dart';

class MockLocationService extends Mock implements LocationService {}
class MockHospitalRepository extends Mock implements HospitalRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}
class MockSosRepository extends Mock implements SosRepository {}
class MockHapticService extends Mock implements HapticService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocationService mockLocationService;
  late MockHospitalRepository mockHospitalRepository;
  late MockProfileRepository mockProfileRepository;
  late MockSosRepository mockSosRepository;
  late MockHapticService mockHapticService;
  late SosNotifier notifier;

  setUpAll(() {
    registerFallbackValue(
      Position(
        longitude: 0,
        latitude: 0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      ),
    );
    registerFallbackValue(
      const Hospital(
        id: '1',
        name: 'Test',
        address: 'Test',
        latitude: 0,
        longitude: 0,
        distanceMeters: 100,
        emergencyPhone: '112',
      ),
    );
  });

  setUp(() {
    mockLocationService = MockLocationService();
    mockHospitalRepository = MockHospitalRepository();
    mockProfileRepository = MockProfileRepository();
    mockSosRepository = MockSosRepository();
    mockHapticService = MockHapticService();

    when(() => mockHapticService.touchDown()).thenAnswer((_) async {});
    when(() => mockHapticService.triggerConfirmed()).thenAnswer((_) async {});
    when(() => mockHapticService.successPattern()).thenAnswer((_) async {});
    when(() => mockHapticService.failurePattern()).thenAnswer((_) async {});

    notifier = SosNotifier(
      mockLocationService,
      mockHospitalRepository,
      mockProfileRepository,
      mockSosRepository,
      mockHapticService,
    );
  });

  group('SosNotifier State Machine Unit Tests', () {
    test('Hold flow transitions from idle to holding and back on release', () {
      expect(notifier.state.status, SosStatus.idle);

      notifier.onHoldStart();
      expect(notifier.state.status, SosStatus.holding);
      expect(notifier.state.holdProgress, 0.0);

      notifier.updateHoldProgress(0.5);
      expect(notifier.state.status, SosStatus.holding);
      expect(notifier.state.holdProgress, 0.5);

      notifier.onHoldCancelled();
      expect(notifier.state.status, SosStatus.idle);
      expect(notifier.state.holdProgress, 0.0);
    });

    test('Triggering sequence acquires location, hospital, and dispatches', () async {
      final mockPosition = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 10.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      const mockHospital = Hospital(
        id: 'hosp_sf_1',
        name: 'San Francisco General Hospital',
        address: '1001 Potrero Ave',
        latitude: 37.755,
        longitude: -122.404,
        distanceMeters: 1500,
        emergencyPhone: '911',
      );

      final mockDispatch = SosDispatch(
        id: 'DISP-TEST-01',
        timestamp: DateTime.now(),
        userLatitude: mockPosition.latitude,
        userLongitude: mockPosition.longitude,
        hospital: mockHospital,
        userName: 'John Doe',
        userPhone: '+15551234567',
        userAddress: 'Market St',
        etaMinutes: 5,
        ambulanceUnitNumber: 'MEDIC-99',
        status: 'dispatched',
      );

      when(() => mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => mockPosition);
      when(() => mockHospitalRepository.getNearestHospital(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          )).thenAnswer((_) async => mockHospital);
      when(() => mockProfileRepository.getProfile())
          .thenAnswer((_) async => const UserProfile(
                name: 'John Doe',
                phoneNumber: '+15551234567',
                address: 'Market St',
              ));
      when(() => mockSosRepository.dispatchAmbulance(
            position: any(named: 'position'),
            hospital: any(named: 'hospital'),
            profile: any(named: 'profile'),
          )).thenAnswer((_) async => mockDispatch);

      await notifier.triggerEmergencySequence();

      expect(notifier.state.status, SosStatus.active);
      expect(notifier.state.dispatch?.id, 'DISP-TEST-01');
      expect(notifier.state.dispatch?.ambulanceUnitNumber, 'MEDIC-99');
      expect(notifier.state.dispatch?.etaMinutes, 5);
      verify(() => mockHapticService.triggerConfirmed()).called(1);
      verify(() => mockHapticService.successPattern()).called(1);
    });

    test('Cancel dispatch calls repository and resets state', () async {
      when(() => mockSosRepository.cancelDispatch(any()))
          .thenAnswer((_) async {});

      await notifier.cancelDispatch();

      expect(notifier.state.status, SosStatus.idle);
      expect(notifier.state.dispatch, isNull);
    });
  });
}
