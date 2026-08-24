class ApiConfig {
  // OpenRouteService API Key
  static const String openRouteServiceApiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImIzM2Q3MmE4ZGFmNjRiZGRiZjBlZjUzMTEzMGRjMjMxIiwiaCI6Im11cm11cjY0In0=';
  
  // OpenRouteService endpoints
  static const String openRouteServiceBaseUrl = 'https://api.openrouteservice.org';
  static const String directionsEndpoint = '/v2/directions/driving-car';
  
  // OpenStreetMap (Free alternative - no API key required)
  static const String openStreetMapUrl = 'https://tile.openstreetmap.org';
  
  // Mapbox API Key - Alternative option
  static const String mapboxApiKey = 'YOUR_MAPBOX_API_KEY_HERE';
  static const String mapboxStyleId = 'mapbox/streets-v11';
  
  // Distance calculation settings
  static const int distanceCalculationPrecision = 2; // Decimal places for distance
  static const String distanceUnit = 'km';
}
