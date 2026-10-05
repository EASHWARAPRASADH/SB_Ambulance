import 'package:noble_pasteur/features/hospital/domain/entities/hospital.dart';
import 'package:noble_pasteur/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:noble_pasteur/features/hospital/data/datasources/hospital_remote_data_source.dart';

class HospitalRepositoryImpl implements HospitalRepository {
  final HospitalRemoteDataSource _remoteDataSource;

  HospitalRepositoryImpl(this._remoteDataSource);

  @override
  Future<Hospital> getNearestHospital({
    required double latitude,
    required double longitude,
  }) async {
    return await _remoteDataSource.fetchNearestHospital(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
