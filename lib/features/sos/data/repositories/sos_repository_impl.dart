import 'package:geolocator/geolocator.dart';
import 'package:noble_pasteur/features/hospital/domain/entities/hospital.dart';
import 'package:noble_pasteur/features/profile/domain/entities/user_profile.dart';
import 'package:noble_pasteur/features/sos/domain/entities/sos_dispatch.dart';
import 'package:noble_pasteur/features/sos/domain/repositories/sos_repository.dart';
import 'package:noble_pasteur/features/sos/data/datasources/sos_remote_data_source.dart';

class SosRepositoryImpl implements SosRepository {
  final SosRemoteDataSource _remoteDataSource;

  SosRepositoryImpl(this._remoteDataSource);

  @override
  Future<SosDispatch> dispatchAmbulance({
    required Position position,
    required Hospital hospital,
    required UserProfile? profile,
  }) async {
    return await _remoteDataSource.sendDispatchPayload(
      latitude: position.latitude,
      longitude: position.longitude,
      hospital: hospital,
      profile: profile,
    );
  }

  @override
  Future<void> cancelDispatch(String dispatchId) async {
    await _remoteDataSource.cancelDispatch(dispatchId);
  }
}
