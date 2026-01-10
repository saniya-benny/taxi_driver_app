import 'package:flutter/material.dart';

class AssignedRidesScreen extends StatefulWidget {
  const AssignedRidesScreen({super.key});

  @override
  State<AssignedRidesScreen> createState() => _AssignedRidesScreenState();
}

class _AssignedRidesScreenState extends State<AssignedRidesScreen> {
  // Sample data for assigned rides
  List<Map<String, dynamic>> assignedRides = [
    {
      'riderName': 'John Doe',
      'pickup': 'Kaloor, Kochi',
      'drop': 'Infopark, Kakkanad',
      'distance': 12.5,
      'fare': 150.0,
      'status': 'Assigned',
      'paymentMode': 'Cash'
    },
    {
      'riderName': 'Alice Smith',
      'pickup': 'Lulu Mall, Kochi',
      'drop': 'Vyttila, Kochi',
      'distance': 8.0,
      'fare': 100.0,
      'status': 'Assigned',
      'paymentMode': 'Online'
    },
  ];

  // Track ongoing ride
  int? ongoingIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: assignedRides.length,
          itemBuilder: (context, index) {
            final ride = assignedRides[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                title: Text(
                  ride['riderName'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(
                    '${ride['pickup']} → ${ride['drop']}\nStatus: ${ride['status']}'),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () => _showRideDetails(index),
              ),
            );
          },
        ),
      ),
    );
  }

  // ----------------------------
  // Popup for Ride Details
  // ----------------------------
  void _showRideDetails(int index) {
    final ride = assignedRides[index];
    bool isOngoing = ongoingIndex == index;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ride['riderName'],
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Pickup: ${ride['pickup']}'),
              Text('Drop: ${ride['drop']}'),
              Text('Distance: ${ride['distance']} km'),
              Text('Payment Mode: ${ride['paymentMode']}'),
              Text('Status: ${ride['status']}'),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (!isOngoing) {
                      // Start Ride
                      setState(() {
                        ongoingIndex = index;
                        assignedRides[index]['status'] = 'Ongoing';
                      });
                      Navigator.pop(context);
                    } else {
                      // End Ride → Show Billing
                      _showBillingDialog(index);
                      setState(() {
                        ongoingIndex = null;
                        assignedRides[index]['status'] = 'Completed';
                      });
                    }
                  },
                  child: Text(!isOngoing ? 'Start Ride' : 'End Ride'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ----------------------------
  // Billing Popup
  // ----------------------------
  void _showBillingDialog(int index) {
    final ride = assignedRides[index];

    // Dummy calculation (you can make reusable later)
    double baseFare = 50;
    double distanceFare = ride['distance'] * 10;
    double totalFare = baseFare + distanceFare;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Billing'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rider: ${ride['riderName']}'),
              Text('Pickup: ${ride['pickup']}'),
              Text('Drop: ${ride['drop']}'),
              const SizedBox(height: 10),
              Text('Base Fare: ₹$baseFare'),
              Text('Distance Fare: ₹$distanceFare'),
              const Divider(),
              Text(
                'Total: ₹$totalFare',
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text('Payment Mode: ${ride['paymentMode']}'),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'))
          ],
        );
      },
    );
  }
}
