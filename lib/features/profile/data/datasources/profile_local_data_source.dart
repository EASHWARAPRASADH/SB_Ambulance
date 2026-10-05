import 'package:shared_preferences/shared_preferences.dart';
import 'package:noble_pasteur/core/errors/exceptions.dart';
import 'package:noble_pasteur/features/profile/data/models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel?> getCachedProfile();
  Future<void> cacheProfile(UserProfileModel profile);
  Future<void> clearProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String _kProfileKey = 'CACHED_USER_PROFILE';
  final SharedPreferences _sharedPreferences;

  ProfileLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<UserProfileModel?> getCachedProfile() async {
    try {
      final jsonString = _sharedPreferences.getString(_kProfileKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        return UserProfileModel.fromRawJson(jsonString);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to read cached profile: $e');
    }
  }

  @override
  Future<void> cacheProfile(UserProfileModel profile) async {
    try {
      await _sharedPreferences.setString(_kProfileKey, profile.toRawJson());
    } catch (e) {
      throw CacheException('Failed to persist profile: $e');
    }
  }

  @override
  Future<void> clearProfile() async {
    try {
      await _sharedPreferences.remove(_kProfileKey);
    } catch (e) {
      throw CacheException('Failed to remove cached profile: $e');
    }
  }
}
