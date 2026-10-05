import 'dart:convert';
import 'package:noble_pasteur/features/hospital/data/models/hospital_model.dart';
import 'package:noble_pasteur/features/hospital/domain/entities/hospital.dart';
import 'package:noble_pasteur/features/sos/domain/entities/sos_dispatch.dart';

class SosDispatchModel extends SosDispatch {
  const SosDispatchModel({
    required super.id,
    required super.timestamp,
    required super.userLatitude,
    required super.userLongitude,
    required super.hospital,
    required super.userName,
    required super.userPhone,
    required super.userAddress,
    super.bloodGroup,
    super.medicalNotes,
    required super.etaMinutes,
    required super.ambulanceUnitNumber,
    required super.status,
  });

  factory SosDispatchModel.fromJson(Map<String, dynamic> json) {
    final hospData = json['hospital'];
    Hospital hosp;
    if (hospData is Map<String, dynamic>) {
      hosp = HospitalModel.fromJson(hospData);
    } else {
      hosp = const Hospital(
        id: 'hosp_fallback',
        name: 'Emergency Medical Hospital',
        address: 'Downtown Medical District',
        latitude: 0,
        longitude: 0,
        distanceMeters: 1000,
        emergencyPhone: '112',
      );
    }

    return SosDispatchModel(
      id: json['id'] as String? ?? 'dispatch_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      userLatitude: (json['userLatitude'] as num?)?.toDouble() ?? 0.0,
      userLongitude: (json['userLongitude'] as num?)?.toDouble() ?? 0.0,
      hospital: hosp,
      userName: json['userName'] as String? ?? 'Anonymous Citizen',
      userPhone: json['userPhone'] as String? ?? 'Unknown',
      userAddress: json['userAddress'] as String? ?? 'GPS Coordinates Provided',
      bloodGroup: json['bloodGroup'] as String?,
      medicalNotes: json['medicalNotes'] as String?,
      etaMinutes: json['etaMinutes'] as int? ?? 6,
      ambulanceUnitNumber: json['ambulanceUnitNumber'] as String? ?? 'MEDIC-42',
      status: json['status'] as String? ?? 'dispatched',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'hospital': {
        'id': hospital.id,
        'name': hospital.name,
        'address': hospital.address,
        'latitude': hospital.latitude,
        'longitude': hospital.longitude,
        'distanceMeters': hospital.distanceMeters,
        'emergencyPhone': hospital.emergencyPhone,
      },
      'userName': userName,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'bloodGroup': bloodGroup,
      'medicalNotes': medicalNotes,
      'etaMinutes': etaMinutes,
      'ambulanceUnitNumber': ambulanceUnitNumber,
      'status': status,
    };
  }

  String toRawJson() => jsonEncode(toJson());
}
