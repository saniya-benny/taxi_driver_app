import 'package:flutter/material.dart';
import '../widgets/bill_sheet.dart';

class AssignedRidesPage extends StatelessWidget {
  const AssignedRidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rides = [
      {
        'rider': 'John Doe',
        'pickup': 'Kaloor, Kochi',
        'drop': 'Infopark, Kakkanad',
        'distance': 12.5,
        'fare': 150,
      },
      {
        'rider': 'Alice Smith',
        'pickup': 'Lulu Mall, Kochi',
        'drop': 'Vyttila, Kochi',
        'distance': 8,
        'fare': 100,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),

      /// APP BAR (matches screenshot style)
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2A3A),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Taxi Admin',
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
            ),
            SizedBox(height: 4),
            Text(
              'Live Rides',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.refresh,color: Colors.white,),
          )
        ],
      ),

      /// BODY
      body: rides.isEmpty
          ? _EmptyState()
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ride = rides[index];

          return InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _RideDetailSheet(ride: ride),
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
                    ride['rider'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  _locationRow(
                      Icons.circle, ride['pickup'], Colors.green),
                  const SizedBox(height: 8),
                  _locationRow(Icons.location_on, ride['drop'], Colors.red),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${ride['distance']} km',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '₹${ride['fare']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
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
}

/// ================= EMPTY STATE =================

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.assignment_late,
              size: 64, color: Colors.grey),
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
  const _RideDetailSheet({required this.ride});

  @override
  State<_RideDetailSheet> createState() => _RideDetailSheetState();
}

class _RideDetailSheetState extends State<_RideDetailSheet> {
  bool rideStarted = false;

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
              ride['rider'],
              style:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _detailRow('Pickup', ride['pickup']),
            _detailRow('Drop', ride['drop']),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${ride['distance']} km'),
                Text('₹${ride['fare']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 32),

            if (!rideStarted)
              OutlinedButton(
                onPressed: () {
                  setState(() => rideStarted = true);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF0B2A3A)),
                ),
                child: const Text(
                  'Start Ride',
                  style: TextStyle(color: Color(0xFF0B2A3A)),
                ),
              ),

            if (rideStarted)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) =>
                        BillSheet(amount: ride['fare'].toDouble()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF0B2A3A),
                ),
                child: const Text('End Ride',style: TextStyle(color: Colors.white),),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
