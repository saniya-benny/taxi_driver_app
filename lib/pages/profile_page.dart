import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../services/api_client.dart';
import '../services/api_exceptions.dart';
import '../services/secure_storage_service.dart';
import 'login_page.dart';
import 'package:intl/intl.dart';
import '../widgets/no_internet_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiClient _apiClient = ApiClient();

  DriverProfile? _driverProfile;
  bool _isLoading = true;
  bool _noInternet = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDriverProfile();
  }

  Future<void> _loadDriverProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _noInternet = false;
    });

    try {
      final response = await _apiClient.getDriverProfile();
      final profileResponse = DriverProfileResponse.fromJson(response);

      if (!mounted) return;

      setState(() {
        _driverProfile = profileResponse.data.driver;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      // 🔐 Session expired → ApiClient already redirected
      if (e is ApiException && e.statusCode == 401) {
        return;
      }

      // 🌐 No Internet
      if (e is ApiException && e.message == 'NO_INTERNET') {
        setState(() {
          _noInternet = true;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _error = e is ApiException ? e.message : e.toString();
      });
    }
  }

  Future<void> _logout() async {
    await SecureStorageService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B2A3A),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2A3A),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDriverProfile,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 🌐 No Internet UI
    if (_noInternet) {
      return NoInternetScreen(
        onRetry: _loadDriverProfile,
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_driverProfile == null) {
      return const Center(child: Text('No profile data'));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: Color(0xFF0B2A3A),
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                _driverProfile!.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _driverProfile!.phone_number,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        _ProfileRow(
          icon: Icons.directions_car,
          title: 'Vehicle Number',
          value: _driverProfile!.vehicle_number,
        ),
        _divider(),
        _ProfileRow(
          icon: Icons.badge,
          title: 'License Number',
          value: _driverProfile!.license_number,
        ),
        _divider(),
        _ProfileRow(
          icon: Icons.calendar_today,
          title: 'Member Since',
          value: _formatDate(_driverProfile!.created_at),
        ),

        const SizedBox(height: 40),

        ElevatedButton(
          onPressed: _showLogoutDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B2A3A),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// UI formatting only
  String _formatDate(DateTime date) {
    final istDate = date.add(const Duration(hours: 5, minutes: 30));
    return DateFormat('dd/MM/yyyy, hh:mm a').format(istDate);
  }

  Widget _divider() => const Divider(height: 24);
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0B2A3A)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(title, style: const TextStyle(color: Colors.grey)),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
