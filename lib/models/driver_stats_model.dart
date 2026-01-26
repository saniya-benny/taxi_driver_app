import 'package:json_annotation/json_annotation.dart';

part 'driver_stats_model.g.dart';

/// ================= DAILY =================

@JsonSerializable()
class DailyStats {
  final String? date;
  final String? total_rides;
  final String? total_earnings;
  final String? total_minutes;
  final String? total_hours;

  DailyStats({
    this.date,
    this.total_rides,
    this.total_earnings,
    this.total_minutes,
    this.total_hours,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) =>
      _$DailyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DailyStatsToJson(this);

  /// Safe getters
  int get totalRides => int.tryParse(total_rides ?? '0') ?? 0;
  double get totalEarnings => double.tryParse(total_earnings ?? '0') ?? 0.0;
  double get totalMinutes => double.tryParse(total_minutes ?? '0') ?? 0.0;
  double get totalHours => double.tryParse(total_hours ?? '0') ?? 0.0;
}

/// ================= WEEKLY =================

@JsonSerializable()
class WeeklyStats {
  final String? week_start;
  final String? week_end;
  final String? total_rides;
  final String? total_earnings;
  final String? total_minutes;
  final String? total_hours;

  WeeklyStats({
    this.week_start,
    this.week_end,
    this.total_rides,
    this.total_earnings,
    this.total_minutes,
    this.total_hours,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) =>
      _$WeeklyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$WeeklyStatsToJson(this);

  /// Safe getters
  int get totalRides => int.tryParse(total_rides ?? '0') ?? 0;
  double get totalEarnings => double.tryParse(total_earnings ?? '0') ?? 0.0;
  double get totalMinutes => double.tryParse(total_minutes ?? '0') ?? 0.0;
  double get totalHours => double.tryParse(total_hours ?? '0') ?? 0.0;
}

/// ================= MONTHLY =================

@JsonSerializable()
class MonthlyStats {
  final String? month;
  final String? total_rides;
  final String? total_earnings;
  final String? total_minutes;
  final String? total_hours;

  MonthlyStats({
    this.month,
    this.total_rides,
    this.total_earnings,
    this.total_minutes,
    this.total_hours,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyStatsToJson(this);

  /// Safe getters
  int get totalRides => int.tryParse(total_rides ?? '0') ?? 0;
  double get totalEarnings => double.tryParse(total_earnings ?? '0') ?? 0.0;
  double get totalMinutes => double.tryParse(total_minutes ?? '0') ?? 0.0;
  double get totalHours => double.tryParse(total_hours ?? '0') ?? 0.0;
}

/// ================= GENERIC RESPONSE =================

@JsonSerializable(genericArgumentFactories: true)
class StatsResponse<T> {
  final bool success;
  final T? data;

  StatsResponse({
    required this.success,
    this.data,
  });

  factory StatsResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) =>
      _$StatsResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$StatsResponseToJson(this, toJsonT);
}
