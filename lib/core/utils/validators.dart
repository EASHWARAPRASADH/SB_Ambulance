class Validators {
  Validators._();

  static final RegExp _phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required for emergency dispatch';
    }
    final sanitized = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_phoneRegExp.hasMatch(sanitized)) {
      return 'Enter a valid 10-15 digit phone number';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required for location verification';
    }
    if (value.trim().length < 5) {
      return 'Please provide a more descriptive address';
    }
    return null;
  }

  static String? validateOptionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final sanitized = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_phoneRegExp.hasMatch(sanitized)) {
      return 'Enter a valid 10-15 digit phone number';
    }
    return null;
  }
}
