import '../../domain/entities/hospital.dart';

class HospitalModel extends Hospital {
  const HospitalModel({
    required super.id,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.distanceMeters,
    required super.emergencyPhone,
    super.rating,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String? ?? json['place_id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Nearest Medical Center',
      address: json['address'] as String? ?? json['vicinity'] as String? ?? 'Emergency Facility',
      latitude: (json['latitude'] as num?)?.toDouble() ??
          (json['geometry']?['location']?['lat'] as num?)?.toDouble() ??
          0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ??
          (json['geometry']?['location']?['lng'] as num?)?.toDouble() ??
          0.0,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ??
          (json['distance'] as num?)?.toDouble() ??
          1200.0,
      emergencyPhone: json['emergencyPhone'] as String? ??
          json['formatted_phone_number'] as String? ??
          '112',
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distanceMeters': distanceMeters,
      'emergencyPhone': emergencyPhone,
      'rating': rating,
    };
  }
}
