import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noble_pasteur/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:noble_pasteur/features/profile/data/models/user_profile_model.dart';
import 'package:noble_pasteur/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:noble_pasteur/features/profile/domain/entities/user_profile.dart';
import 'package:noble_pasteur/features/profile/presentation/providers/profile_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late ProfileLocalDataSource dataSource;
  late ProfileRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = ProfileLocalDataSourceImpl(prefs);
    repository = ProfileRepositoryImpl(dataSource);
  });

  group('Profile Repository Tests', () {
    test('Returns null when no profile is cached', () async {
      final profile = await repository.getProfile();
      expect(profile, isNull);
    });

    test('Caches and retrieves complete UserProfile correctly', () async {
      const user = UserProfile(
        name: 'Sarah Connor',
        phoneNumber: '+15550192834',
        address: '42 Tech Blvd, Neo City',
        bloodGroup: 'O+',
        medicalNotes: 'No allergies',
        emergencyContactPhone: '+15559998888',
      );

      await repository.saveProfile(user);
      final fetched = await repository.getProfile();

      expect(fetched, isNotNull);
      expect(fetched!.name, 'Sarah Connor');
      expect(fetched.phoneNumber, '+15550192834');
      expect(fetched.address, '42 Tech Blvd, Neo City');
      expect(fetched.bloodGroup, 'O+');
      expect(fetched.isComplete, isTrue);
    });

    test('UserProfileModel json serialization works round-trip', () {
      const model = UserProfileModel(
        name: 'John Doe',
        phoneNumber: '1234567890',
        address: 'Main St',
        bloodGroup: 'AB+',
      );

      final json = model.toJson();
      final parsed = UserProfileModel.fromJson(json);

      expect(parsed.name, model.name);
      expect(parsed.phoneNumber, model.phoneNumber);
      expect(parsed.bloodGroup, model.bloodGroup);
    });

    test('ProfileNotifier loads and saves state successfully', () async {
      final notifier = ProfileNotifier(repository);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.valueOrNull, isNull);

      const profile = UserProfile(
        name: 'Alex Mercer',
        phoneNumber: '+1987654321',
        address: 'Penn Station Area',
      );

      final success = await notifier.saveProfile(profile);
      expect(success, isTrue);
      expect(notifier.state.valueOrNull?.name, 'Alex Mercer');
    });
  });
}
