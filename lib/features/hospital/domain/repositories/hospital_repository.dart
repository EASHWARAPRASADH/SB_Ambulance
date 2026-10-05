import '../entities/hospital.dart';

abstract class HospitalRepository {
  Future<Hospital> getNearestHospital({
    required double latitude,
    required double longitude,
  });
}
