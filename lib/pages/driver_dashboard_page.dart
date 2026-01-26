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
      if (e is ApiException && e.statusCode == 401) {
        return; // 🔥 already redirected to Login by ApiClient
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
        title: const Text(
          'TraveLink',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final data = _currentStats!;
    final date = _getDateDisplay(data);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          /// ✅ FIXED GRID
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25, // ⭐ MORE HEIGHT → NO OVERFLOW
            ),
            itemBuilder: (context, index) {
              final items = [
                _StatItem(
                  icon: Icons.route,
                  title: 'Total Rides',
                  value: data['total_rides']?.toString() ?? '0',
                ),
                _StatItem(
                  icon: Icons.currency_rupee,
                  title: 'Earnings',
                  value: data['total_earnings'] == null
                      ? '—'
                      : '₹${data['total_earnings']}',
                ),
                _StatItem(
                  icon: Icons.access_time,
                  title: 'Hours',
                  value: data['total_hours'] == null
                      ? '—'
                      : '${data['total_hours']} hrs',
                ),
                _StatItem(
                  icon: Icons.timer,
                  title: 'Minutes',
                  value: data['total_minutes'] == null
                      ? '—'
                      : '${data['total_minutes']} min',
                ),
              ];

              return _StatCard(item: items[index]);
            },
          ),
        ],
      ),
    );
  }

  String _getDateDisplay(Map<String, dynamic> data) {
    if (_selectedPeriod == 'Daily' && data['date'] != null) {
      return data['date'];
    }
    if (_selectedPeriod == 'Weekly') {
      return '${data['week_start']} - ${data['week_end']}';
    }
    if (_selectedPeriod == 'Monthly') {
      return data['month'] ?? '';
    }
    return '';
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
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            const Icon(Icons.keyboard_arrow_down,
                color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// ================= DATA MODEL =================

class _StatItem {
  final IconData icon;
  final String title;
  final String value;

  _StatItem({
    required this.icon,
    required this.title,
    required this.value,
  });
}

/// ================= STAT CARD (NO OVERFLOW) =================

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: const Color(0xFF0B2A3A), size: 24),
          const Spacer(), // ⭐ KEY FIX
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}