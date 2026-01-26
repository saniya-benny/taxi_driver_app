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
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ================= LOGIN =================

  Future<LoginResponse> driverLogin(
      String phoneNumber, String password) async {
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

  // ================= PROFILE =================

  Future<DriverProfile> getDriverProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/drivers/profile'),
        headers: _headers,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final profileResponse =
        DriverProfileResponse.fromJson(responseData);
        return profileResponse.data.driver;
      } else {
        throw ApiException(
            responseData['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // ================= DAILY STATS =================

  Future<DailyStats?> getDailyStats({String? date}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/drivers/stats/daily');
      final requestUri =
      date != null ? uri.replace(queryParameters: {'date': date}) : uri;

      final response = await http.get(requestUri, headers: _headers);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final statsResponse = StatsResponse<DailyStats>.fromJson(
          responseData,
              (json) => DailyStats.fromJson(json as Map<String, dynamic>),
        );
        return statsResponse.data;
      } else {
        throw ApiException(
            responseData['message'] ?? 'Failed to fetch daily stats');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // ================= WEEKLY STATS =================

  Future<WeeklyStats?> getWeeklyStats({String? date}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/drivers/stats/weekly');
      final requestUri =
      date != null ? uri.replace(queryParameters: {'date': date}) : uri;

      final response = await http.get(requestUri, headers: _headers);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final statsResponse = StatsResponse<WeeklyStats>.fromJson(
          responseData,
              (json) => WeeklyStats.fromJson(json as Map<String, dynamic>),
        );
        return statsResponse.data;
      } else {
        throw ApiException(
            responseData['message'] ?? 'Failed to fetch weekly stats');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // ================= MONTHLY STATS =================

  Future<MonthlyStats?> getMonthlyStats({String? date}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/drivers/stats/monthly');
      final requestUri =
      date != null ? uri.replace(queryParameters: {'date': date}) : uri;

      final response = await http.get(requestUri, headers: _headers);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final statsResponse = StatsResponse<MonthlyStats>.fromJson(
          responseData,
              (json) => MonthlyStats.fromJson(json as Map<String, dynamic>),
        );
        return statsResponse.data;
      } else {
        throw ApiException(
            responseData['message'] ?? 'Failed to fetch monthly stats');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
}

//
// ================= LOGIN RESPONSE MODELS =================
//

class LoginResponse {
  final bool success;
  final LoginData data;

  LoginResponse({
    required this.success,
    required this.data,
  });

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

  LoginData({
    this.token,
    this.driver,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'],
      driver: json['driver'] != null
          ? DriverInfo.fromJson(json['driver'])
          : null,
    );
  }
}

class DriverInfo {
  final String id;
  final String name;
  final String phone_number;

  DriverInfo({
    required this.id,
    required this.name,
    required this.phone_number,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phone_number: json['phone_number'] ?? '',
    );
  }
}
