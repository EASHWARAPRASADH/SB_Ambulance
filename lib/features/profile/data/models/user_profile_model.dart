import 'dart:convert';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.name,
    required super.phoneNumber,
    required super.address,
    super.bloodGroup,
    super.medicalNotes,
    super.emergencyContactPhone,
  });

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      bloodGroup: entity.bloodGroup,
      medicalNotes: entity.medicalNotes,
      emergencyContactPhone: entity.emergencyContactPhone,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      bloodGroup: json['bloodGroup'] as String?,
      medicalNotes: json['medicalNotes'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'bloodGroup': bloodGroup,
      'medicalNotes': medicalNotes,
      'emergencyContactPhone': emergencyContactPhone,
    };
  }

  String toRawJson() => jsonEncode(toJson());

  factory UserProfileModel.fromRawJson(String str) =>
      UserProfileModel.fromJson(jsonDecode(str) as Map<String, dynamic>);
}
