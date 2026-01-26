import 'package:flutter/material.dart';
import '../models/driver_stats_model.dart';
import '../services/api_client.dart';
import '../services/api_exceptions.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late TabController _tabController;

  DailyStats? _dailyStats;
  WeeklyStats? _weeklyStats;
  MonthlyStats? _monthlyStats;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // ✅ Daily (required)
      final daily = await _apiClient.getDailyStats();
      debugPrint('DAILY OK');

      // ✅ Weekly (required)
      final weekly = await _apiClient.getWeeklyStats();
      debugPrint('WEEKLY OK');

      // ⚠️ Monthly (optional)
      Map<String, dynamic>? monthly;
      try {
        monthly = await _apiClient.getMonthlyStats();
        debugPrint('MONTHLY OK');
      } catch (e) {
        debugPrint('MONTHLY FAILED (ignored): $e');
      }

      setState(() {
        _dailyStats =
        daily['data'] != null ? DailyStats.fromJson(daily['data']) : null;

        _weeklyStats =
        weekly['data'] != null ? WeeklyStats.fromJson(weekly['data']) : null;

        _monthlyStats =
        monthly != null && monthly['data'] != null
            ? MonthlyStats.fromJson(monthly['data'])
            : null;

        _isLoading = false;
      });
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;

      debugPrint('STATISTICS ERROR: $e');

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
          'Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllStats,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
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
              'Error loading statistics',
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
              onPressed: _loadAllStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _DailyStatsView(stats: _dailyStats),
        _WeeklyStatsView(stats: _weeklyStats),
        _MonthlyStatsView(stats: _monthlyStats),
      ],
    );
  }
}

/// ================= DAILY =================

class _DailyStatsView extends StatelessWidget {
  final DailyStats? stats;
  const _DailyStatsView({this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Center(child: Text('No daily statistics available'));
    }

    return _StatsCard(
      title: 'Daily Summary',
      date: stats!.date ?? '—',

      stats: [
        _StatItem(
          icon: Icons.directions_car,
          label: 'Total Rides',
          value: stats!.totalRides.toString(),
          color: Colors.blue,
        ),
        _StatItem(
          icon: Icons.attach_money,
          label: 'Earnings',
          value: '₹${stats!.totalEarnings.toStringAsFixed(0)}',
          color: Colors.green,
        ),
        _StatItem(
          icon: Icons.access_time,
          label: 'Total Time',
          value: '${stats!.totalHours.toStringAsFixed(1)} hrs',
          color: Colors.orange,
        ),
      ],
    );
  }
}

/// ================= WEEKLY =================

class _WeeklyStatsView extends StatelessWidget {
  final WeeklyStats? stats;
  const _WeeklyStatsView({this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Center(child: Text('No weekly statistics available'));
    }

    return _StatsCard(
      title: 'Weekly Summary',
      date: '${stats!.week_start ?? '—'} to ${stats!.week_end ?? '—'}',
      stats: [
        _StatItem(
          icon: Icons.directions_car,
          label: 'Total Rides',
          value: stats!.totalRides.toString(),
          color: Colors.blue,
        ),
        _StatItem(
          icon: Icons.attach_money,
          label: 'Earnings',
          value: '₹${stats!.totalEarnings.toStringAsFixed(0)}',
          color: Colors.green,
        ),
        _StatItem(
          icon: Icons.access_time,
          label: 'Total Time',
          value: '${stats!.totalHours.toStringAsFixed(1)} hrs',
          color: Colors.orange,
        ),
      ],
    );
  }
}

/// ================= MONTHLY =================

class _MonthlyStatsView extends StatelessWidget {
  final MonthlyStats? stats;
  const _MonthlyStatsView({this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Center(child: Text('No monthly statistics available'));
    }

    return _StatsCard(
      title: 'Monthly Summary',
      date: _formatMonth(stats!.month),
      stats: [
        _StatItem(
          icon: Icons.directions_car,
          label: 'Total Rides',
          value: stats!.totalRides.toString(),
          color: Colors.blue,
        ),
        _StatItem(
          icon: Icons.attach_money,
          label: 'Earnings',
          value: '₹${stats!.totalEarnings.toStringAsFixed(0)}',
          color: Colors.green,
        ),
        _StatItem(
          icon: Icons.access_time,
          label: 'Total Time',
          value: '${stats!.totalHours.toStringAsFixed(1)} hrs',
          color: Colors.orange,
        ),
      ],
    );
  }

  String _formatMonth(String? monthString) {
    if (monthString == null || monthString.isEmpty) return '—';

    try {
      final date = DateTime.parse(monthString);
      const months = [
        'January','February','March','April','May','June',
        'July','August','September','October','November','December'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return monthString;
    }
  }
}

/// ================= COMMON UI =================

class _StatsCard extends StatelessWidget {
  final String title;
  final String date;
  final List<_StatItem> stats;

  const _StatsCard({
    required this.title,
    required this.date,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B2A3A))),
            const SizedBox(height: 4),
            Text(date,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            ...stats.map(
                  (stat) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _StatItemWidget(stat: stat),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItemWidget extends StatelessWidget {
  final _StatItem stat;
  const _StatItemWidget({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stat.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stat.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(stat.icon, color: stat.color, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.label,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(stat.value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B2A3A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
