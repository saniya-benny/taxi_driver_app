import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../config/api_config.dart';

class RouteService {
  static final RouteService _instance = RouteService._internal();
  factory RouteService() => _instance;
  RouteService._internal();

  /// Get route between two points using OpenRouteService
  Future<RouteResult?> getRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.openRouteServiceBaseUrl}${ApiConfig.directionsEndpoint}',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': ApiConfig.openRouteServiceApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'coordinates': [
            [startLng, startLat], // OpenRouteService uses [lng, lat] format
            [endLng, endLat],
          ],
          'instructions': false,
          'geometry': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['features'] != null && data['features'].isNotEmpty) {
          final feature = data['features'][0];
          final geometry = feature['geometry'];
          
          if (geometry['coordinates'] != null) {
            // Convert coordinates to LatLng list
            final coordinates = geometry['coordinates'] as List;
            final List<LatLng> polylinePoints = [];
            
            for (var coord in coordinates) {
              try {
                if (coord is List && coord.length >= 2) {
                  // OpenRouteService returns [lng, lat] format
                  double lng = double.parse(coord[0].toString());
                  double lat = double.parse(coord[1].toString());
                  polylinePoints.add(LatLng(lat, lng));
                }
              } catch (e) {
                print('Error converting coordinate: $coord, error: $e');
              }
            }

            // Get distance from properties if available
            double distance = 0.0;
            String? roadName;
            String? instruction;
            
            if (feature['properties'] != null) {
              final properties = feature['properties'];
              
              // Get distance from segments
              if (properties['segments'] != null && 
                  properties['segments'].isNotEmpty) {
                distance = (properties['segments'][0]['distance'] ?? 0.0) / 1000.0; // Convert to km
              }
              
              // Get road name and instruction from summary
              if (properties['summary'] != null) {
                final summary = properties['summary'];
                roadName = summary['name'];
                instruction = summary['instruction'] ?? 'Follow the route';
              }
            }

            return RouteResult(
              polylinePoints: polylinePoints,
              distance: distance,
              duration: feature['properties']?['summary']?['duration'],
              roadName: roadName,
              instruction: instruction,
            );
          } // <- Add missing closing brace
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting route: $e');
      return null;
    }
  }

  /// Calculate straight-line distance between two points
  double calculateStraightLineDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final Distance distance = const Distance();
    return distance.as(
      LengthUnit.Kilometer,
      LatLng(startLat, startLng),
      LatLng(endLat, endLng),
    );
  }
}

class RouteResult {
  final List<LatLng> polylinePoints;
  final double distance; // in kilometers
  final int? duration; // in seconds
  final String? roadName;
  final String? instruction;

  RouteResult({
    required this.polylinePoints,
    required this.distance,
    this.duration,
    this.roadName,
    this.instruction,
  });
}
