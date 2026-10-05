import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../errors/exceptions.dart';

class LocationService {
  final GeolocatorPlatform _geolocator;
  final http.Client _httpClient;

  LocationService({
    GeolocatorPlatform? geolocator,
    http.Client? httpClient,
  })  : _geolocator = geolocator ?? GeolocatorPlatform.instance,
        _httpClient = httpClient ?? http.Client();

  /// Silently checks current permission status
  Future<LocationPermission> checkPermission() async {
    try {
      return await _geolocator.checkPermission();
    } catch (e) {
      return LocationPermission.denied;
    }
  }

  /// Requests permission from the user
  Future<LocationPermission> requestPermission() async {
    try {
      return await _geolocator.requestPermission();
    } catch (e) {
      return LocationPermission.denied;
    }
  }

  /// Checks if location services (GPS) are toggled on
  Future<bool> isLocationServiceEnabled() async {
    if (kIsWeb) return true;
    try {
      return await _geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Complete emergency flow: ensures enabled GPS + permissions, then returns coordinates
  Future<Position> getCurrentLocation() async {
    if (kIsWeb) {
      return await _getWebLocation();
    } else {
      return await _getMobileLocation();
    }
  }

  /// Dedicated robust location resolver for Web browsers
  Future<Position> _getWebLocation() async {
    // 1. Try high-accuracy browser geolocation (triggers browser permission prompt)
    try {
      return await _geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      // High-accuracy can fail or time out on PCs/laptops without a GPS chip
    }

    // 2. Try standard/low-accuracy browser geolocation (uses WiFi/cell triangulation)
    try {
      return await _geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 6),
        ),
      );
    } catch (_) {
      // Browser location was blocked or unavailable
    }

    // 3. Fallback: IP-based Geolocation lookup (ensures location NEVER fails during emergency)
    try {
      final ipPosition = await _getIpFallbackPosition();
      if (ipPosition != null) {
        return ipPosition;
      }
    } catch (_) {}

    throw LocationPermissionDeniedException(
      'Location access was denied or unavailable in your browser. Please allow location permissions in your browser address bar and retry.',
    );
  }

  /// Dedicated location resolver for native Android and iOS
  Future<Position> _getMobileLocation() async {
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
      try {
        final lastKnown = await _geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return lastKnown;
        }
      } catch (_) {}

      // Fallback to IP geolocation if GPS hardware has no satellite fix
      final ipPos = await _getIpFallbackPosition();
      if (ipPos != null) {
        return ipPos;
      }

      throw AppException('Failed to acquire GPS fix: $e');
    }
  }

  /// Resilient network IP geolocation fallback (CORS friendly)
  Future<Position?> _getIpFallbackPosition() async {
    try {
      final uri = Uri.parse('https://ipwho.is/');
      final res = await _httpClient.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final lat = (data['latitude'] as num).toDouble();
          final lon = (data['longitude'] as num).toDouble();
          return Position(
            latitude: lat,
            longitude: lon,
            timestamp: DateTime.now(),
            accuracy: 1000.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
        }
      }
    } catch (_) {
      // Try secondary backup
      try {
        final uri = Uri.parse('https://get.geojs.io/v1/ip/geo.json');
        final res = await _httpClient.get(uri).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final lat = double.tryParse(data['latitude']?.toString() ?? '') ?? 0.0;
          final lon = double.tryParse(data['longitude']?.toString() ?? '') ?? 0.0;
          if (lat != 0.0 && lon != 0.0) {
            return Position(
              latitude: lat,
              longitude: lon,
              timestamp: DateTime.now(),
              accuracy: 1500.0,
              altitude: 0.0,
              altitudeAccuracy: 0.0,
              heading: 0.0,
              headingAccuracy: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
            );
          }
        }
      } catch (_) {}
    }
    return null;
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
