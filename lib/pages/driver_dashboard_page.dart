import 'package:flutter/material.dart';

class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({super.key});

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  String _selectedPeriod = 'Daily';

  final Map<String, Map<String, dynamic>> dashboardData = {
    'Daily': {
      "date": "12 Jan 2026",
      "total_rides": 0,
      "total_earnings": 0,
      "total_minutes": 0,
      "total_hours": 0,
    },
    'Weekly': {
      "date": "Week 2, 2026",
      "total_rides": 12,
      "total_earnings": 2400,
      "total_minutes": 780,
      "total_hours": 13,
    },
    'Monthly': {
      "date": "January 2026",
      "total_rides": 46,
      "total_earnings": 9200,
      "total_minutes": 3120,
      "total_hours": 52,
    },
  };

  @override
  Widget build(BuildContext context) {
    final data = dashboardData[_selectedPeriod]!;

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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _PeriodDropdown(
              value: _selectedPeriod,
              onChanged: (value) {
                setState(() => _selectedPeriod = value);
              },
            ),
          ),
        ],
      ),

      /// BODY
      body: Padding(
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
              data['date'],
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
                  value: data['total_rides'].toString(),
                ),
                _StatCard(
                  icon: Icons.currency_rupee,
                  title: 'Earnings',
                  value: data['total_earnings'] == 0
                      ? '—'
                      : '₹${data['total_earnings']}',
                ),
                _StatCard(
                  icon: Icons.access_time,
                  title: 'Hours',
                  value: data['total_hours'] == 0
                      ? '—'
                      : '${data['total_hours']} hrs',
                ),
                _StatCard(
                  icon: Icons.timer,
                  title: 'Minutes',
                  value: data['total_minutes'] == 0
                      ? '—'
                      : '${data['total_minutes']} min',
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
