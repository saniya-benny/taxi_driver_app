import 'package:flutter/material.dart';
import 'widgets/nav_item.dart';
import 'pages/assigned_rides_page.dart';
import 'pages/driver_dashboard_page.dart';
import 'pages/ride_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AssignedRidesPage(),
    DriverDashboardPage(),
    RideHistoryPage(),
  ];

  void _onTabSelected(int index) {
    if (index != _currentIndex) setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: const LinearGradient(
                colors: [Color(0xFF0B2A3A), Color(0xFF1F4B5C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavItem(icon: Icons.home, index: 0, isSelected: _currentIndex == 0, onTap: _onTabSelected),
                NavItem(icon: Icons.drive_eta, index: 1, isSelected: _currentIndex == 1, onTap: _onTabSelected),
                NavItem(icon: Icons.history, index: 2, isSelected: _currentIndex == 2, onTap: _onTabSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}