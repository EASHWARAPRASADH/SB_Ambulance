import 'package:geolocator/geolocator.dart';
import '../errors/exceptions.dart';

class LocationService {
  final GeolocatorPlatform _geolocator;

  LocationService({GeolocatorPlatform? geolocator})
      : _geolocator = geolocator ?? GeolocatorPlatform.instance;

  /// Silently checks current permission status
  Future<LocationPermission> checkPermission() async {
    try {
      return await _geolocator.checkPermission();
    } catch (e) {
      throw LocationDisabledException('Unable to check location status: $e');
    }
  }

  /// Requests permission from the user
  Future<LocationPermission> requestPermission() async {
    try {
      return await _geolocator.requestPermission();
    } catch (e) {
      throw LocationDisabledException('Unable to request location permissions: $e');
    }
  }

  /// Checks if location services (GPS) are toggled on
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await _geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Complete emergency flow: ensures enabled GPS + permissions, then returns coordinates
  Future<Position> getCurrentLocation() async {
    final isEnabled = await isLocationServiceEnabled();
    if (!isEnabled) {
      throw LocationDisabledException(
        'GPS is disabled. Please enable device location for emergency dispatch.',
      );
    }

    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException(
          'Location access is required to dispatch responders to your position.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionPermanentlyDeniedException(
        'Location permission is permanently denied. Please grant location access in device settings.',
      );
    }

    try {
      return await _geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (e) {
      // In case high accuracy times out, try last known position as fallback
      final lastKnown = await _geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }
      throw AppException('Failed to acquire GPS fix: $e');
    }
  }

  /// Open app settings if permanently denied
  Future<bool> openAppSettings() async {
    try {
      return await _geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Open location settings if GPS hardware is turned off
  Future<bool> openLocationSettings() async {
    try {
      return await _geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }
}
