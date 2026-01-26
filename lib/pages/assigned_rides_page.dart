import 'package:flutter/material.dart';
import '../widgets/bill_sheet.dart';
import '../services/api_client.dart';
import '../services/api_exceptions.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAssignedRides();
  }

  Future<void> _loadAssignedRides() async {
    setState(() {
      _isLoading = true;
      _error = null;
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
        } else if (response['rides'] is List) {
          _rides = List<Map<String, dynamic>>.from(response['rides']);
        } else {
          _rides = [];
        }
        _isLoading = false;
      });
    } catch (e) {
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
      return _EmptyState();
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
                onRideAction: _loadAssignedRides,
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
                      formatToIST(ride['requested_at']), // ✅ FIXED
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}

/// ================= EMPTY STATE =================

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
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

/// ================= RIDE DETAIL SHEET =================

class _RideDetailSheet extends StatefulWidget {
  final Map<String, dynamic> ride;
  final VoidCallback onRideAction;
  const _RideDetailSheet({required this.ride, required this.onRideAction});

  @override
  State<_RideDetailSheet> createState() => _RideDetailSheetState();
}

class _RideDetailSheetState extends State<_RideDetailSheet> {
  bool _isStarting = false;
  bool _isEnding = false;
  final ApiClient _apiClient = ApiClient();

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
              'Ride ID: ${ride['id']?.toString().substring(0, 8) ?? 'Unknown'}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _detailRow('Pickup', ride['pickup_address'] ?? 'Pickup location'),
            _detailRow('Drop', ride['drop_address'] ?? 'Drop location'),
            const SizedBox(height: 16),

            // ✅ Fixed overflow here using Expanded
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Status: ${ride['status'] ?? 'Unknown'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Requested: ${formatToIST(ride['requested_at'])}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),

            if (ride['assigned_at'] != null) ...[
              const SizedBox(height: 8),
              Text('Assigned: ${formatToIST(ride['assigned_at'])}'),
            ],

            const SizedBox(height: 32),

            if (ride['status'] == 'assigned')
              _isStarting
                  ? const Center(child: CircularProgressIndicator())
                  : OutlinedButton(
                      onPressed: _startRide,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF0B2A3A)),
                      ),
                      child: const Text(
                        'Start Ride',
                        style: TextStyle(color: Color(0xFF0B2A3A)),
                      ),
                    ),

            if (ride['status'] == 'in_progress')
              _isEnding
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _endRide,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF0B2A3A),
                      ),
                      child: const Text(
                        'End Ride',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRide() async {
    setState(() => _isStarting = true);
    try {
      await _apiClient.startRide(widget.ride['id']);
      if (mounted) {
        Navigator.pop(context);
        widget.onRideAction();
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        return; // 🔥 already redirected
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to start ride: $e')));
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<void> _endRide() async {
    setState(() => _isEnding = true);
    try {
      await _apiClient.endRide(widget.ride['id']);
      if (mounted) {
        Navigator.pop(context);
        widget.onRideAction();
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        return; // 🔥 already redirected
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to end ride: $e')));
      }
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
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
  } catch (e) {
    return dateString;
  }
}
