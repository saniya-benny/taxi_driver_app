import 'api_client.dart';
import '../models/driver_model.dart';
import '../models/driver_stats_model.dart';
import '../models/ride_model.dart';

class DriverApiService {
  static final DriverApiService _instance = DriverApiService._internal();
  factory DriverApiService() => _instance;
  DriverApiService._internal();

  final ApiClient _apiClient = ApiClient();

  // ================= RIDE MANAGEMENT =================

  /// Get assigned rides for the driver
  Future<RideResponse> getAssignedRides() async {
    try {
      final response = await _apiClient.getAssignedRides();
      print(response); // Debug log
      return RideResponse.fromJson(response);
    } catch (e) {
      print('Error in getAssignedRides: $e'); // Debug log
      throw Exception('Failed to get assigned rides: $e');
    }
  }

  /// Start a ride
  Future<RideActionResponse> startRide(String rideId) async {
    try {
      final response = await _apiClient.startRide(rideId);
      return RideActionResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to start ride: $e');
    }
  }

  /// End a ride
  Future<RideActionResponse> endRide(String rideId) async {
    try {
      final response = await _apiClient.endRide(rideId);
      return RideActionResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to end ride: $e');
    }
  }

  /// Get ride history
  Future<RideHistoryResponse> getRideHistory({
    int limit = 20,
    int offset = 0,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _apiClient.getRideHistory(
        limit: limit,
        offset: offset,
        startDate: startDate,
        endDate: endDate,
      );
      print('Ride History API Response: $response'); // Debug log
      return RideHistoryResponse.fromJson(response);
    } catch (e) {
      print('Error in getRideHistory: $e'); // Debug log
      throw Exception('Failed to get ride history: $e');
    }
  }

  // ================= DRIVER PROFILE =================

  /// Get driver profile information
  Future<DriverProfile> getDriverProfile() async {
    try {
      final response = await _apiClient.getDriverProfile();
      final profileResponse = DriverProfileResponse.fromJson(response);
      return profileResponse.data.driver;
    } catch (e) {
      throw Exception('Failed to get driver profile: $e');
    }
  }

  // ================= STATISTICS =================

  /// Get daily statistics
  Future<DailyStats?> getDailyStats({String? date}) async {
    try {
      final response = await _apiClient.getDailyStats(date: date);
      if (response['success'] == true && response['data'] != null) {
        return DailyStats.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get daily stats: $e');
    }
  }

  /// Get weekly statistics
  Future<WeeklyStats?> getWeeklyStats({String? date}) async {
    try {
      final response = await _apiClient.getWeeklyStats(date: date);
      if (response['success'] == true && response['data'] != null) {
        return WeeklyStats.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get weekly stats: $e');
    }
  }

  /// Get monthly statistics
  Future<MonthlyStats?> getMonthlyStats({String? date}) async {
    try {
      final response = await _apiClient.getMonthlyStats(date: date);
      if (response['success'] == true && response['data'] != null) {
        return MonthlyStats.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get monthly stats: $e');
    }
  }

  // ================= AUTHENTICATION =================

  /// Driver login
  Future<Map<String, dynamic>> driverLogin(String phoneNumber, String password) async {
    try {
      return await _apiClient.driverLogin(phoneNumber, password);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  /// Check if driver is authenticated
  bool get isAuthenticated => _apiClient.isAuthenticated;

  /// Clear authentication token
  Future<void> logout() async {
    await _apiClient.clearToken();
  }
}
