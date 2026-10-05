class ApiConstants {
  ApiConstants._();

  // In production, this can be provided via --dart-define or environment config
  static const String googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '',
  );

  static const String placesNearbySearchUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  // Backend dispatcher mock / production endpoint
  static const String dispatchEndpointUrl = String.fromEnvironment(
    'DISPATCH_API_URL',
    defaultValue: 'https://api.emergency-dispatch.local/v1/dispatch',
  );
}
