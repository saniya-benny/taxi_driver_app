// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyStats _$DailyStatsFromJson(Map<String, dynamic> json) => DailyStats(
  date: json['date'] as String,
  total_rides: json['total_rides'] as String,
  total_earnings: json['total_earnings'] as String?,
  total_minutes: json['total_minutes'] as String?,
  total_hours: json['total_hours'] as String?,
);

Map<String, dynamic> _$DailyStatsToJson(DailyStats instance) =>
    <String, dynamic>{
      'date': instance.date,
      'total_rides': instance.total_rides,
      'total_earnings': instance.total_earnings,
      'total_minutes': instance.total_minutes,
      'total_hours': instance.total_hours,
    };

WeeklyStats _$WeeklyStatsFromJson(Map<String, dynamic> json) => WeeklyStats(
  week_start: json['week_start'] as String,
  week_end: json['week_end'] as String,
  total_rides: json['total_rides'] as String,
  total_earnings: json['total_earnings'] as String,
  total_minutes: json['total_minutes'] as String,
  total_hours: json['total_hours'] as String,
);

Map<String, dynamic> _$WeeklyStatsToJson(WeeklyStats instance) =>
    <String, dynamic>{
      'week_start': instance.week_start,
      'week_end': instance.week_end,
      'total_rides': instance.total_rides,
      'total_earnings': instance.total_earnings,
      'total_minutes': instance.total_minutes,
      'total_hours': instance.total_hours,
    };

MonthlyStats _$MonthlyStatsFromJson(Map<String, dynamic> json) => MonthlyStats(
  month: json['month'] as String,
  total_rides: json['total_rides'] as String,
  total_earnings: json['total_earnings'] as String,
  total_minutes: json['total_minutes'] as String,
  total_hours: json['total_hours'] as String,
);

Map<String, dynamic> _$MonthlyStatsToJson(MonthlyStats instance) =>
    <String, dynamic>{
      'month': instance.month,
      'total_rides': instance.total_rides,
      'total_earnings': instance.total_earnings,
      'total_minutes': instance.total_minutes,
      'total_hours': instance.total_hours,
    };

StatsResponse<T> _$StatsResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => StatsResponse<T>(
  success: json['success'] as bool,
  data: fromJsonT(json['data']),
);

Map<String, dynamic> _$StatsResponseToJson<T>(
  StatsResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'data': toJsonT(instance.data),
};
