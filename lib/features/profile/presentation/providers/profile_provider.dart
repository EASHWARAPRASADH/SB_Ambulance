import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noble_pasteur/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:noble_pasteur/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:noble_pasteur/features/profile/domain/entities/user_profile.dart';
import 'package:noble_pasteur/features/profile/domain/repositories/profile_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProfileLocalDataSourceImpl(prefs);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final localDataSource = ref.watch(profileLocalDataSourceProvider);
  return ProfileRepositoryImpl(localDataSource);
});

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveProfile(UserProfile profile) async {
    try {
      await _repository.saveProfile(profile);
      state = AsyncValue.data(profile);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> clearProfile() async {
    try {
      await _repository.clearProfile();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});
