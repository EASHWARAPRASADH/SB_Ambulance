class AppException implements Exception {
  final String message;
  final dynamic cause;

  AppException(this.message, [this.cause]);

  @override
  String toString() => message;
}

class LocationDisabledException extends AppException {
  LocationDisabledException([
    super.message = 'Location services are disabled on this device.',
  ]);
}

class LocationPermissionDeniedException extends AppException {
  LocationPermissionDeniedException([
    super.message = 'Location permission was denied.',
  ]);
}

class LocationPermissionPermanentlyDeniedException extends AppException {
  LocationPermissionPermanentlyDeniedException([
    super.message =
        'Location permission is permanently denied. Please enable it in system settings.',
  ]);
}

class HospitalNotFoundException extends AppException {
  HospitalNotFoundException([
    super.message = 'No registered hospital facility found within radius.',
  ]);
}

class DispatchFailedException extends AppException {
  DispatchFailedException([
    super.message = 'Failed to transmit emergency dispatch payload.',
  ]);
}

class CacheException extends AppException {
  CacheException([super.message = 'Local cache operation failed.']);
}
