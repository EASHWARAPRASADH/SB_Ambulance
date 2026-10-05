class UserProfile {
  final String name;
  final String phoneNumber;
  final String address;
  final String? bloodGroup;
  final String? medicalNotes;
  final String? emergencyContactPhone;

  const UserProfile({
    required this.name,
    required this.phoneNumber,
    required this.address,
    this.bloodGroup,
    this.medicalNotes,
    this.emergencyContactPhone,
  });

  bool get isComplete =>
      name.trim().isNotEmpty &&
      phoneNumber.trim().isNotEmpty &&
      address.trim().isNotEmpty;

  UserProfile copyWith({
    String? name,
    String? phoneNumber,
    String? address,
    String? bloodGroup,
    String? medicalNotes,
    String? emergencyContactPhone,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
    );
  }

  static const empty = UserProfile(
    name: '',
    phoneNumber: '',
    address: '',
  );
}
