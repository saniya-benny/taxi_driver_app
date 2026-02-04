import 'package:flutter/material.dart';
import '../models/driver_stats_model.dart';
import '../services/driver_api_service.dart';
import '../services/api_exceptions.dart';
import '../widgets/no_internet_screen.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  final DriverApiService _driverApiService = DriverApiService();
  late TabController _tabController;

  DailyStats? _dailyStats;
  WeeklyStats? _weeklyStats;
  MonthlyStats? _monthlyStats;

  bool _isLoading = true;
  bool _noInternet = false;
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
      _noInternet = false;
    });

    try {
      final daily = await _driverApiService.getDailyStats();
      final weekly = await _driverApiService.getWeeklyStats();

      MonthlyStats? monthly;
      try {
        monthly = await _driverApiService.getMonthlyStats();
      } catch (_) {
        // monthly is optional → ignore failure
      }

      if (!mounted) return;

      setState(() {
        _dailyStats = daily;
        _weeklyStats = weekly;
        _monthlyStats = monthly;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      if (e is ApiException && e.message == 'NO_INTERNET') {
        setState(() {
          _isLoading = false;
          _noInternet = true;
        });
        return;
      }

      if (e is ApiException && e.statusCode == 401) return;

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

    if (_noInternet) {
      return NoInternetScreen(onRetry: _loadAllStats);
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
              style: const TextStyle(color: Colors.grey),
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
        _StatsView(
          title: 'Daily Summary',
          date: _dailyStats?.date ?? '—',
          stats: _dailyStats,
        ),
        _StatsView(
          title: 'Weekly Summary',
          date: _weeklyStats == null
              ? '—'
              : '${_weeklyStats!.week_start} to ${_weeklyStats!.week_end}',
          stats: _weeklyStats,
        ),
        _StatsView(
          title: 'Monthly Summary',
          date: _monthlyStats?.month ?? '—',
          stats: _monthlyStats,
        ),
      ],
    );
  }
}

/// ================= COMMON CARD =================

class _StatsView extends StatelessWidget {
  final String title;
  final String date;
  final dynamic stats;

  const _StatsView({
    required this.title,
    required this.date,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
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

            _StatRow('Total Rides', stats.totalRides.toString(), Icons.route),
            _StatRow('Earnings', '₹${stats.totalEarnings.toStringAsFixed(0)}',
                Icons.currency_rupee),
            _StatRow(
                'Total Time',
                '${stats.totalHours.toStringAsFixed(1)} hrs',
                Icons.access_time),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0B2A3A)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Text(value,
              style:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      ),
    );
  }
}
