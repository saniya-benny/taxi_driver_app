import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/api_exceptions.dart';

class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({super.key});

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  String _selectedPeriod = 'Daily';
  final ApiClient _apiClient = ApiClient();
  
  Map<String, dynamic>? _currentStats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Map<String, dynamic> response;
      
      switch (_selectedPeriod) {
        case 'Daily':
          response = await _apiClient.getDailyStats();
          break;
        case 'Weekly':
          response = await _apiClient.getWeeklyStats();
          break;
        case 'Monthly':
          response = await _apiClient.getMonthlyStats();
          break;
        default:
          response = await _apiClient.getDailyStats();
      }

      setState(() {
        _currentStats = response['data'];
        _isLoading = false;
      });
    } catch (e) {
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

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2A3A),
        elevation: 0,
        title: const Text(
          'Taxi Admin',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
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
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _PeriodDropdown(
                value: _selectedPeriod,
                onChanged: (value) {
                  setState(() => _selectedPeriod = value);
                  _loadStats();
                },
              ),
            ),
        ],
      ),

      /// BODY
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading statistics',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_currentStats == null) {
      return const Center(
        child: Text('No statistics available'),
      );
    }

    final data = _currentStats!;
    final date = _getDateDisplay(data);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          /// STATS GRID
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            children: [
              _StatCard(
                icon: Icons.route,
                title: 'Total Rides',
                value: data['total_rides']?.toString() ?? '0',
              ),
              _StatCard(
                icon: Icons.currency_rupee,
                title: 'Earnings',
                value: data['total_earnings'] == null || data['total_earnings'] == 0
                    ? '—'
                    : '₹${data['total_earnings']}',
              ),
              _StatCard(
                icon: Icons.access_time,
                title: 'Hours',
                value: data['total_hours'] == null || data['total_hours'] == 0
                    ? '—'
                    : '${data['total_hours']} hrs',
              ),
              _StatCard(
                icon: Icons.timer,
                title: 'Minutes',
                value: data['total_minutes'] == null || data['total_minutes'] == 0
                    ? '—'
                    : '${data['total_minutes']} min',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDateDisplay(Map<String, dynamic> data) {
    if (_selectedPeriod == 'Daily' && data['date'] != null) {
      return data['date'];
    } else if (_selectedPeriod == 'Weekly' && data['week_start'] != null && data['week_end'] != null) {
      return '${data['week_start']} - ${data['week_end']}';
    } else if (_selectedPeriod == 'Monthly' && data['month'] != null) {
      return data['month'];
    }
    return _selectedPeriod;
  }
}

/// ================= PERIOD DROPDOWN =================

class _PeriodDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _PeriodDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'Daily', child: Text('Daily')),
        PopupMenuItem(value: 'Weekly', child: Text('Weekly')),
        PopupMenuItem(value: 'Monthly', child: Text('Monthly')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

/// ================= STAT CARD =================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0B2A3A)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
