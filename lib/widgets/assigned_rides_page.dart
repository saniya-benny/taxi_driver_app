import 'package:flutter/material.dart';


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
      {
        'rider': 'Bob Johnson',
        'pickup': 'MG Road, Kochi',
        'drop': 'Fort Kochi, Kochi',
        'distance': 15,
        'fare': 200,
      },
    ];

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];

          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _RideDetailSheet(ride: ride),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B2A3A), Color(0xFF1F4B5C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 8, offset: Offset(0, 6))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride['rider'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Column(
                          children: const [
                            Icon(Icons.circle, size: 12, color: Colors.white),
                            SizedBox(height: 2),
                            Icon(Icons.more_vert, size: 20, color: Colors.white),
                            SizedBox(height: 2),
                            Icon(Icons.location_on, size: 12, color: Colors.white),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride['pickup'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              const SizedBox(height: 20),
                              Text(ride['drop'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Distance: ${ride['distance']} km',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        Text('Fare: ₹${ride['fare']}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



class _RideDetailSheet extends StatelessWidget {
  final Map<String, dynamic> ride;
  const _RideDetailSheet({required this.ride});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.circle, color: Colors.green),
                SizedBox(width: 10),
                Text("Pickup", style: TextStyle(fontSize: 16)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 5, bottom: 15),
              child: Text(ride['pickup'], style: const TextStyle(fontSize: 16)),
            ),
            Row(
              children: const [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 10),
                Text("Drop", style: TextStyle(fontSize: 16)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 5, bottom: 15),
              child: Text(ride['drop'], style: const TextStyle(fontSize: 16)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Distance: ${ride['distance']} km",
                    style: const TextStyle(fontSize: 16)),
                Text("Fare: ₹${ride['fare']}",
                    style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {},
                    child: const Text('Start', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      // Close ride sheet
                      Navigator.pop(context);
                      // Show premium billing
                      _showBilling(context, ride['fare']);
                    },
                    child: const Text('End', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showBilling(BuildContext context, double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: 250,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Billing",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("Total Amount: ₹$amount",
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(fontSize: 20)),
              )
            ],
          ),
        );
      },
    );
  }
}