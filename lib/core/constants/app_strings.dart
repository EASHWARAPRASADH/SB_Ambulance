class AppStrings {
  AppStrings._();

  static const String appTitle = 'AMBULANCE SOS';
  static const String sosButtonText = 'HOLD FOR\nAMBULANCE';
  static const String sosHoldPrompt = 'Keep holding to dispatch';
  static const String cancelText = 'Cancel SOS';
  static const String emergencyNumber = '112'; // Global emergency fallback
  static const String altEmergencyNumber = '911';

  // Status Messages
  static const String acquiringLocation = 'Pinpointing your GPS location...';
  static const String findingHospital = 'Locating nearest emergency facility...';
  static const String dispatchingAmbulance = 'Dispatching ambulance unit...';
  static const String dispatchConfirmed = 'AMBULANCE DISPATCHED';
  static const String dispatchCancelled = 'Dispatch has been cancelled';

  // Profile Strings
  static const String profileTitle = 'Emergency Medical Profile';
  static const String profileSubtitle = 'This info is transmitted to responders upon SOS.';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String address = 'Primary Address';
  static const String bloodGroup = 'Blood Group (Optional)';
  static const String medicalNotes = 'Allergies / Critical Conditions (Optional)';
  static const String emergencyContact = 'Emergency Contact Phone (Optional)';
  static const String saveProfile = 'Save Emergency Profile';
  static const String profileSavedSuccess = 'Profile saved securely';
}
