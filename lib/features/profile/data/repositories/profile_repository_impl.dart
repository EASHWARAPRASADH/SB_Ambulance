import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _localDataSource;

  ProfileRepositoryImpl(this._localDataSource);

  @override
  Future<UserProfile?> getProfile() async {
    final model = await _localDataSource.getCachedProfile();
    return model;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final model = UserProfileModel.fromEntity(profile);
    await _localDataSource.cacheProfile(model);
  }

  @override
  Future<void> clearProfile() async {
    await _localDataSource.clearProfile();
  }
}
