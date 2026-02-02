import 'package:json_annotation/json_annotation.dart';

part 'driver_model.g.dart';

@JsonSerializable()
class DriverProfile {
  final String id;
  final String name;
  final String phone_number;
  final String license_number;
  final String vehicle_number;

  final String? address;
  final String? pincode;

  final bool is_active;
  final bool is_available;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime created_at;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime last_login;

  final DriverStats stats;

  DriverProfile({
    required this.id,
    required this.name,
    required this.phone_number,
    required this.license_number,
    required this.vehicle_number,
    this.address,          // ✅ nullable
    this.pincode,          // ✅ nullable
    required this.is_active,
    required this.is_available,
    required this.created_at,
    required this.last_login,
    required this.stats,
  });


  factory DriverProfile.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileFromJson(json);

  Map<String, dynamic> toJson() => _$DriverProfileToJson(this);
}


@JsonSerializable()
class DriverStats {
  final int total_rides;
  final int completed_rides;
  final double total_earnings;
  final double avg_fare;

  DriverStats({
    required this.total_rides,
    required this.completed_rides,
    required this.total_earnings,
    required this.avg_fare,
  });

  factory DriverStats.fromJson(Map<String, dynamic> json) =>
      _$DriverStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DriverStatsToJson(this);
}

@JsonSerializable()
class DriverProfileResponse {
  final bool success;
  final DriverProfileData data;

  DriverProfileResponse({
    required this.success,
    required this.data,
  });

  factory DriverProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DriverProfileResponseToJson(this);
}

@JsonSerializable()
class DriverProfileData {
  final DriverProfile driver;

  DriverProfileData({
    required this.driver,
  });

  factory DriverProfileData.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$DriverProfileDataToJson(this);
}

/// =======================================================
/// DATE & TIME HANDLING — BACKEND SENDS UTC (NO TIMEZONE)
/// Convert UTC → IST (Asia/Kolkata) EXACTLY ONCE
/// =======================================================

DateTime _dateTimeFromJson(String value) {
  // Normalize "yyyy-MM-dd HH:mm:ss" → ISO
  final normalized = value.contains(' ')
      ? value.replaceFirst(' ', 'T')
      : value;

  // Treat backend time as UTC
  final utcTime = DateTime.parse(normalized).toUtc();

  // Convert UTC → IST (+05:30)
  return utcTime.add(const Duration(hours: 5, minutes: 30));
}

String _dateTimeToJson(DateTime date) {
  // Always send UTC back to backend
  return date.toUtc().toIso8601String();
}
