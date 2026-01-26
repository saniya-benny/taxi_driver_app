import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_exceptions.dart';
import 'package:taxi_driver/pages/login_page.dart';
import 'package:taxi_driver/main.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static const String baseUrl = "https://api.lenienttree.org";
  static const String _tokenKey = 'auth_token';

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;

  // Token Management
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
    }
    return _token;
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  bool get isAuthenticated => _token != null;

  // HTTP Headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // HTTP Methods
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final responseBody = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      // Handle 401 Unauthorized - clear token and redirect to login
      if (response.statusCode == 401) {
        await clearToken();
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginPage()),
              (route) => false,
        );
        throw ApiException('Session expired. Please login again.', 401);
      }

      final message = responseBody['message'] ?? 'Request failed';
      throw ApiException(message, response.statusCode);
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    await getToken(); // Ensure token is loaded

    final uri = Uri.parse('$baseUrl$endpoint');
    final requestUri = queryParams != null ? uri.replace(queryParameters: queryParams) : uri;

    final response = await http.get(requestUri, headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    await getToken(); // Ensure token is loaded

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    await getToken(); // Ensure token is loaded

    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    await getToken(); // Ensure token is loaded

    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Specific API Methods
  Future<Map<String, dynamic>> driverLogin(String phoneNumber, String password) async {
    final response = await post('/api/drivers/login', body: {
      'phone_number': phoneNumber,
      'password': password,
    });

    if (response['success'] == true && response['data']?['token'] != null) {
      await setToken(response['data']['token']);
    }

    return response;
  }

  Future<Map<String, dynamic>> getDriverProfile() async {
    return await get('/api/drivers/profile');
  }

  Future<Map<String, dynamic>> getDailyStats({String? date}) async {
    final queryParams = date != null ? {'date': date} : null;
    return await get('/api/drivers/stats/daily', queryParams: queryParams);
  }

  Future<Map<String, dynamic>> getWeeklyStats({String? date}) async {
    final queryParams = date != null ? {'date': date} : null;
    return await get('/api/drivers/stats/weekly', queryParams: queryParams);
  }

  Future<Map<String, dynamic>> getMonthlyStats({String? date}) async {
    final queryParams = date != null ? {'date': date} : null;
    return await get('/api/drivers/stats/monthly', queryParams: queryParams);
  }

  Future<Map<String, dynamic>> getAssignedRides() async {
    return await get('/api/drivers/rides/assigned');
  }

  Future<Map<String, dynamic>> startRide(String rideId) async {
    return await post('/api/drivers/rides/start', body: {'ride_id': rideId});
  }

  Future<Map<String, dynamic>> endRide(String rideId) async {
    return await post('/api/drivers/rides/end', body: {'ride_id': rideId});
  }

  Future<Map<String, dynamic>> getRideHistory({
    int limit = 20,
    int offset = 0,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    return await get('/api/drivers/rides/history', queryParams: queryParams);
  }
}