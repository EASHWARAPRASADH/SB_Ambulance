import 'package:geolocator/geolocator.dart';
import 'package:noble_pasteur/features/hospital/domain/entities/hospital.dart';
import 'package:noble_pasteur/features/profile/domain/entities/user_profile.dart';
import 'package:noble_pasteur/features/sos/domain/entities/sos_dispatch.dart';

abstract class SosRepository {
  Future<SosDispatch> dispatchAmbulance({
    required Position position,
    required Hospital hospital,
    required UserProfile? profile,
  });

  Future<void> cancelDispatch(String dispatchId);
}
