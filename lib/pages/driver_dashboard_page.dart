import 'package:flutter/material.dart';

class DriverDashboardPage extends StatelessWidget {
  const DriverDashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.drive_eta, size: 80, color: Color(0xFF0B2A3A)),
              SizedBox(height: 24),
              Text('Driver Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Manage your rides efficiently', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}