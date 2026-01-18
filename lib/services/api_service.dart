import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/driver_model.dart';
import '../models/driver_stats_model.dart';
import 'api_exceptions.dart';

class ApiService {
  static const String baseUrl = "https://api.lenienttree.org";
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token!',
      };

  // Driver Login
  Future<LoginResponse> driverLogin(String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/drivers/login'),
        headers: _headers,
        body: jsonEncode({
          'phone_number': phoneNumber,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(responseData);
        if (loginResponse.success && loginResponse.data.token != null) {
          setToken(loginResponse.data.token!);
        }
        return loginResponse;
      } else {
        throw ApiException(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Get Driver Profile
  Future<DriverProfile> getDriverProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/drivers/profile'),
        headers: _headers,
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final profileResponse = DriverProfileResponse.fromJson(responseData);
        return profileResponse.data.driver;
      } else {
        throw ApiException(responseData['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Get Daily Stats
  Future<DailyStats> getDailyStats({String? date}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/drivers/stats/daily');
      final requestUri = date != null 
          ? uri.replace(queryParameters: {'date': date})
          : uri;

      final response = await http.get(requestUri, headers: _headers);
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return StatsResponse<DailyStats>.fromJson(
          responseData,
          (json) => DailyStats.fromJson(json as Map<String, dynamic>),
        ).data;
      } else {
        throw ApiException(responseData['message'] ?? 'Failed to fetch daily stats');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Get Weekly Stats
  Future<WeeklyStats> getWeeklyStats({String? date}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/drivers/stats/weekly');
      final requestUri = date != null 
          ? uri.replace(queryParameters: {'date': date})
          : uri;

      final response = await http.get(requestUri, headers: _headers);
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return StatsResponse<WeeklyStats>.fromJson(
          responseData,
          (json) => WeeklyStats.fromJson(json as Map<String, dynamic>),
        ).data;
      } else {
        throw ApiException(responseData['message'] ?? 'Failed to fetch weekly stats');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Get Monthly Stats
  Future<MonthlyStats> getMonthlyStats({String? date}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/drivers/stats/monthly');
      final requestUri = date != null 
          ? uri.replace(queryParameters: {'date': date})
          : uri;

      final response = await http.get(requestUri, headers: _headers);
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return StatsResponse<MonthlyStats>.fromJson(
          responseData,
          (json) => MonthlyStats.fromJson(json as Map<String, dynamic>),
        ).data;
      } else {
        throw ApiException(responseData['message'] ?? 'Failed to fetch monthly stats');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Get Assigned Rides
  Future<List<dynamic>> getAssignedRides() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/drivers/rides/assigned'),
        headers: _headers,
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return responseData['data'] ?? [];
      } else {
        throw ApiException(responseData['message'] ?? 'Failed to fetch assigned rides');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Start Ride
  Future<Map<String, dynamic>> startRide(String rideId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/drivers/rides/start'),
        headers: _headers,
        body: jsonEncode({'ride_id': rideId}),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return responseData['data']['ride'];
      } else {
        throw ApiException(responseData['message'] ?? 'Failed to start ride');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // End Ride
  Future<Map<String, dynamic>> endRide(String rideId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/drivers/rides/end'),
        headers: _headers,
        body: jsonEncode({'ride_id': rideId}),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return responseData['data'];
      } else {
        throw ApiException(responseData['message'] ?? 'Failed to end ride');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Get Ride History
  Future<List<dynamic>> getRideHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/drivers/rides/history');
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      


      final requestUri = uri.replace(queryParameters: queryParams);

      final response = await http.get(requestUri, headers: _headers);
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return responseData['data'] ?? [];
      } else {
        throw ApiException(responseData['message'] ?? 'Failed to fetch ride history');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
}

// Login Response Models
class LoginResponse {
  final bool success;
  final LoginData data;

  LoginResponse({required this.success, required this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      data: LoginData.fromJson(json['data'] ?? {}),
    );
  }
}

class LoginData {
  final String? token;
  final DriverInfo? driver;

  LoginData({this.token, this.driver});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'],
      driver: json['driver'] != null ? DriverInfo.fromJson(json['driver']) : null,
    );
  }
}

class DriverInfo {
  final String id;
  final String name;
  final String phone_number;

  DriverInfo({required this.id, required this.name, required this.phone_number});

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone_number: json['phone_number'] ?? '',
    );
  }
}
