import 'package:noble_pasteur/features/hospital/domain/entities/hospital.dart';

class SosDispatch {
  final String id;
  final DateTime timestamp;
  final double userLatitude;
  final double userLongitude;
  final Hospital hospital;
  final String userName;
  final String userPhone;
  final String userAddress;
  final String? bloodGroup;
  final String? medicalNotes;
  final int etaMinutes;
  final String ambulanceUnitNumber;
  final String status; // 'dispatched', 'en_route', 'cancelled'

  const SosDispatch({
    required this.id,
    required this.timestamp,
    required this.userLatitude,
    required this.userLongitude,
    required this.hospital,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    this.bloodGroup,
    this.medicalNotes,
    required this.etaMinutes,
    required this.ambulanceUnitNumber,
    required this.status,
  });

  SosDispatch copyWith({
    String? status,
  }) {
    return SosDispatch(
      id: id,
      timestamp: timestamp,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      hospital: hospital,
      userName: userName,
      userPhone: userPhone,
      userAddress: userAddress,
      bloodGroup: bloodGroup,
      medicalNotes: medicalNotes,
      etaMinutes: etaMinutes,
      ambulanceUnitNumber: ambulanceUnitNumber,
      status: status ?? this.status,
    );
  }
}
