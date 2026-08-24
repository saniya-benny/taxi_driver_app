import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';
import '../services/route_service.dart';
import '../models/ride_model.dart';
import '../config/api_config.dart';

class PickupLocationMapPage extends StatefulWidget {
  final Ride ride;

  const PickupLocationMapPage({
    super.key,
    required this.ride,
  });

  @override
  State<PickupLocationMapPage> createState() => _PickupLocationMapPageState();
}

class _PickupLocationMapPageState extends State<PickupLocationMapPage> {
  final LocationService _locationService = LocationService();
  final RouteService _routeService = RouteService();
  final MapController _mapController = MapController();

  Position? _currentPosition;
  LatLng? _pickupLocation;
  RouteResult? _routeResult;

  bool _isLoading = true;
  bool _isLoadingRoute = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      _currentPosition = await _locationService.getCurrentLocation();

      if (widget.ride.pickup_lat != null && widget.ride.pickup_lng != null) {
        _pickupLocation =
            LatLng(widget.ride.pickup_lat!, widget.ride.pickup_lng!);
      }

      if (_currentPosition != null && _pickupLocation != null) {
        setState(() => _isLoadingRoute = true);

        _routeResult = await _routeService.getRoute(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          _pickupLocation!.latitude,
          _pickupLocation!.longitude,
        );

        setState(() => _isLoadingRoute = false);
      }

      setState(() => _isLoading = false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMapToBounds();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingRoute = false;
        _errorMessage = 'Failed to load map: $e';
      });
    }
  }

  void _fitMapToBounds() {
    if (_currentPosition != null && _pickupLocation != null) {
      final bounds = LatLngBounds.fromPoints([
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        _pickupLocation!,
      ]);

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    } else if (_pickupLocation != null) {
      _mapController.move(_pickupLocation!, 15);
    }
  }

  void _centerOnCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15,
      );
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;

    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Location'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnCurrentLocation,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    final route = _routeResult;

    return Column(
      children: [
        // INFO PANEL
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pickup: ${widget.ride.displayPickupAddress}',
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (route != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Distance: ${route.distance.toStringAsFixed(ApiConfig.distanceCalculationPrecision)} ${ApiConfig.distanceUnit}',
                ),
                const SizedBox(height: 4),
                Text('ETA: ${_formatDuration(route.duration ?? 0)}'),
                if (route.roadName?.isNotEmpty == true)
                  Text('Via: ${route.roadName}',
                      style: const TextStyle(color: Colors.grey)),
              ],
            ],
          ),
        ),

        // MAP
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialZoom: 15,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate:
                '${ApiConfig.openStreetMapUrl}/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.taxi_driver',
              ),

              if (route?.polylinePoints.isNotEmpty == true)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: route!.polylinePoints,
                      strokeWidth: 4,
                      color: Colors.blue.withOpacity(0.7),
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      child:
                      const Icon(Icons.person, color: Colors.green),
                    ),
                  if (_pickupLocation != null)
                    Marker(
                      point: _pickupLocation!,
                      child: const Icon(Icons.location_on,
                          color: Colors.blue),
                    ),
                ],
              ),

              // REQUIRED ATTRIBUTION
    RichAttributionWidget(
    attributions: const [
    TextSourceAttribution(
    '© OpenStreetMap contributors',
    ),
    TextSourceAttribution(
    '© OpenRouteService',
    ),
    ],
    ),

            ],
          ),
        ),
      ],
    );
  }
}
