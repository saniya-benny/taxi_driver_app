import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color primaryColor = Color(0xFF0B2A3A);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Driver App',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

// ----------------------------
// HomePage with modern nav bar
// ----------------------------
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
                _NavItem(icon: Icons.home, index: 0, isSelected: _currentIndex == 0, onTap: _onTabSelected),
                _NavItem(icon: Icons.drive_eta, index: 1, isSelected: _currentIndex == 1, onTap: _onTabSelected),
                _NavItem(icon: Icons.history, index: 2, isSelected: _currentIndex == 2, onTap: _onTabSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------
// Nav item with animated scale
// ----------------------------
class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.3 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Icon(
            icon,
            size: 28,
            color: isSelected ? const Color(0xFF0B2A3A) : Colors.white70,
          ),
        ),
      ),
    );
  }
}

// ----------------------------
// Assigned Rides Page
// ----------------------------


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

/// -----------------------------
/// Ride Detail Sheet (Full Screen)
/// -----------------------------
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

// ----------------------------
// Driver Dashboard Page
// ----------------------------
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

// ----------------------------
// Ride History Page
// ----------------------------
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
