import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/api_exceptions.dart';
import '../widgets/no_internet_screen.dart';

class AssignedRidesPage extends StatefulWidget {
  const AssignedRidesPage({super.key});

  @override
  State<AssignedRidesPage> createState() => _AssignedRidesPageState();
}

class _AssignedRidesPageState extends State<AssignedRidesPage> {
  final ApiClient _apiClient = ApiClient();

  List<Map<String, dynamic>> _rides = [];
  bool _isLoading = true;
  String? _error;
  bool _noInternet = false; // ✅ KEY FLAG

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
      final response = await _apiClient.getAssignedRides();

      setState(() {
        if (response['success'] == true && response['data'] != null) {
          final data = response['data'];
          if (data['rides'] is List) {
            _rides = List<Map<String, dynamic>>.from(data['rides']);
          } else {
            _rides = [];
          }
        } else if (response['data'] is List) {
          _rides = List<Map<String, dynamic>>.from(response['data']);
        } else {
          _rides = [];
        }

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
              'TraveLink',
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

        return Container(
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
                'Ride ID: ${ride['id']?.toString().substring(0, 8) ?? 'Unknown'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _locationRow(
                Icons.circle,
                ride['pickup_address'] ?? 'Pickup location',
                Colors.green,
              ),
              const SizedBox(height: 8),
              _locationRow(
                Icons.location_on,
                ride['drop_address'] ?? 'Drop location',
                Colors.red,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ride['status'] ?? 'Unknown',
                    style: TextStyle(
                      color: _getStatusColor(ride['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    formatToIST(ride['requested_at']),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
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
