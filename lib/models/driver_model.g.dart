// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverProfile _$DriverProfileFromJson(Map<String, dynamic> json) =>
    DriverProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      phone_number: json['phone_number'] as String,
      license_number: json['license_number'] as String,
      vehicle_number: json['vehicle_number'] as String,
      is_active: json['is_active'] as bool,
      is_available: json['is_available'] as bool,
      created_at: json['created_at'] as String,
      last_login: json['last_login'] as String,
      stats: DriverStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DriverProfileToJson(DriverProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone_number': instance.phone_number,
      'license_number': instance.license_number,
      'vehicle_number': instance.vehicle_number,
      'is_active': instance.is_active,
      'is_available': instance.is_available,
      'created_at': instance.created_at,
      'last_login': instance.last_login,
      'stats': instance.stats,
    };

DriverStats _$DriverStatsFromJson(Map<String, dynamic> json) => DriverStats(
  total_rides: (json['total_rides'] as num).toInt(),
  completed_rides: (json['completed_rides'] as num).toInt(),
  total_earnings: (json['total_earnings'] as num).toDouble(),
  avg_fare: (json['avg_fare'] as num).toDouble(),
);

Map<String, dynamic> _$DriverStatsToJson(DriverStats instance) =>
    <String, dynamic>{
      'total_rides': instance.total_rides,
      'completed_rides': instance.completed_rides,
      'total_earnings': instance.total_earnings,
      'avg_fare': instance.avg_fare,
    };

DriverProfileResponse _$DriverProfileResponseFromJson(
  Map<String, dynamic> json,
) => DriverProfileResponse(
  success: json['success'] as bool,
  data: DriverProfileData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DriverProfileResponseToJson(
  DriverProfileResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

DriverProfileData _$DriverProfileDataFromJson(Map<String, dynamic> json) =>
    DriverProfileData(
      driver: DriverProfile.fromJson(json['driver'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DriverProfileDataToJson(DriverProfileData instance) =>
    <String, dynamic>{'driver': instance.driver};
