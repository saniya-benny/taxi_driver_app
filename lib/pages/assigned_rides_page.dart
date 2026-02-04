import 'package:flutter/material.dart';
import '../services/driver_api_service.dart';
import '../models/ride_model.dart';
import '../services/api_exceptions.dart';
import '../widgets/no_internet_screen.dart';

class AssignedRidesPage extends StatefulWidget {
  const AssignedRidesPage({super.key});

  @override
  State<AssignedRidesPage> createState() => _AssignedRidesPageState();
}

class _AssignedRidesPageState extends State<AssignedRidesPage> {
  final DriverApiService _driverApiService = DriverApiService();

  List<Ride> _rides = [];
  bool _isLoading = true;
  String? _error;
  bool _noInternet = false;

  @override
  void initState() {
    super.initState();
    _loadAssignedRides();
  }

  Future<void> _loadAssignedRides() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _noInternet = false;
    });

    try {
      final response = await _driverApiService.getAssignedRides();

      setState(() {
        _rides = response.data;
        _isLoading = false;
      });
    } catch (e) {
      // 🔌 NO INTERNET → SWITCH UI (NO NAVIGATION)
      if (e is ApiException && e.message == 'NO_INTERNET') {
        setState(() {
          _noInternet = true;
          _isLoading = false;
        });
        return;
      }

      // 🔐 SESSION EXPIRED → already handled globally
      if (e is ApiException && e.statusCode == 401) {
        return;
      }

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2A3A),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DriverLink',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Live Rides',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadAssignedRides,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // ✅ NO INTERNET UI (INSIDE PAGE)
    if (_noInternet) {
      return NoInternetScreen(
        onRetry: _loadAssignedRides,
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading rides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAssignedRides,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_rides.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _rides.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ride = _rides[index];

        return InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _RideDetailSheet(
                ride: ride,
                onActionComplete: _loadAssignedRides,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ride ID: ${ride.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _locationRow(
                  Icons.circle,
                  ride.displayPickupAddress,
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _locationRow(
                  Icons.location_on,
                  ride.displayDropoffAddress,
                  Colors.red,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ride.displayStatus,
                      style: TextStyle(
                        color: _getStatusColor(ride.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formatToIST(ride.created_at?.toIso8601String()),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'assigned':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _locationRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No live rides',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
class _RideDetailSheet extends StatefulWidget {
  final Ride ride;
  final VoidCallback onActionComplete;

  const _RideDetailSheet({
    required this.ride,
    required this.onActionComplete,
  });

  @override
  State<_RideDetailSheet> createState() => _RideDetailSheetState();
}

class _RideDetailSheetState extends State<_RideDetailSheet> {
  bool _isStarting = false;
  bool _isEnding = false;
  final DriverApiService _driverApiService = DriverApiService();

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Ride ID: ${widget.ride.id.substring(0, 8)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
            _detailRow('Pickup', widget.ride.displayPickupAddress),
            _detailRow('Drop', widget.ride.displayDropoffAddress),
            if (widget.ride.customer_name != null) ...[
              _detailRow('Customer', widget.ride.displayName),
            ],
            if (widget.ride.customer_phone != null) ...[
              _detailRow('Phone', widget.ride.displayPhone),
            ],
            if (widget.ride.fare != null) ...[
              _detailRow('Fare', widget.ride.displayFare),
            ],

            const SizedBox(height: 32),

            if (widget.ride.status == 'assigned')
              _isStarting
                  ? const Center(child: CircularProgressIndicator())
                  : OutlinedButton(
                      onPressed: _startRide,
                      child: const Text('Start Ride'),
                    ),

            if (widget.ride.status == 'in_progress')
              _isEnding
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _endRide,
                      child: const Text('End Ride'),
                    ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRide() async {
    setState(() => _isStarting = true);
    try {
      await _driverApiService.startRide(widget.ride.id);
      Navigator.pop(context);
      widget.onActionComplete();
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<void> _endRide() async {
    setState(() => _isEnding = true);
    try {
      await _driverApiService.endRide(widget.ride.id);
      Navigator.pop(context);
      widget.onActionComplete();
    } finally {
      if (mounted) setState(() => _isEnding = false);
    }
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}

String formatToIST(String? dateString) {
  if (dateString == null) return 'Unknown';
  try {
    final utcDate = DateTime.parse(dateString);
    final istDate = utcDate.add(const Duration(hours: 5, minutes: 30));

    return '${istDate.day.toString().padLeft(2, '0')}/'
        '${istDate.month.toString().padLeft(2, '0')}/'
        '${istDate.year} '
        '${istDate.hour.toString().padLeft(2, '0')}:'
        '${istDate.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return dateString;
  }
}
