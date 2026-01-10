import 'package:flutter/material.dart';

class RideHistoryPage extends StatelessWidget {
  const RideHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> history = [
      {'rider': 'John Doe', 'fare': 150, 'status': 'Completed', 'date': 'Jan 10'},
      {'rider': 'Alice Smith', 'fare': 100, 'status': 'Completed', 'date': 'Jan 9'},
      {'rider': 'Bob Johnson', 'fare': 200, 'status': 'Completed', 'date': 'Jan 8'},
    ];

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final ride = history[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            shadowColor: Colors.black26,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              title: Text('${ride['rider']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('Fare: ₹${ride['fare']} - ${ride['status']}\nDate: ${ride['date']}', style: const TextStyle(fontSize: 14)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}