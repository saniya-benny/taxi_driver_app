// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ride _$RideFromJson(Map<String, dynamic> json) => Ride(
  id: json['id'] as String,
  customer_name: json['customer_name'] as String?,
  customer_phone: json['customer_phone'] as String?,
  pickup_address: json['pickup_address'] as String?,
  dropoff_address: json['dropoff_address'] as String?,
  pickup_lat: (json['pickup_lat'] as num?)?.toDouble(),
  pickup_lng: (json['pickup_lng'] as num?)?.toDouble(),
  dropoff_lat: (json['dropoff_lat'] as num?)?.toDouble(),
  dropoff_lng: (json['dropoff_lng'] as num?)?.toDouble(),
  fare: (json['fare'] as num?)?.toDouble(),
  status: json['status'] as String?,
  payment_status: json['payment_status'] as String?,
  required_time_hours: (json['required_time_hours'] as num?)?.toInt(),
  pickup_time: _dateTimeFromJson(json['pickup_time'] as String?),
  dropoff_time: _dateTimeFromJson(json['dropoff_time'] as String?),
  created_at: _dateTimeFromJson(json['created_at'] as String?),
);

Map<String, dynamic> _$RideToJson(Ride instance) => <String, dynamic>{
  'id': instance.id,
  'customer_name': instance.customer_name,
  'customer_phone': instance.customer_phone,
  'pickup_address': instance.pickup_address,
  'dropoff_address': instance.dropoff_address,
  'pickup_lat': instance.pickup_lat,
  'pickup_lng': instance.pickup_lng,
  'dropoff_lat': instance.dropoff_lat,
  'dropoff_lng': instance.dropoff_lng,
  'fare': instance.fare,
  'status': instance.status,
  'payment_status': instance.payment_status,
  'required_time_hours': instance.required_time_hours,
  'pickup_time': _dateTimeToJson(instance.pickup_time),
  'dropoff_time': _dateTimeToJson(instance.dropoff_time),
  'created_at': _dateTimeToJson(instance.created_at),
};

RideResponse _$RideResponseFromJson(Map<String, dynamic> json) => RideResponse(
  success: json['success'] as bool,
  data: (json['data'] as List<dynamic>)
      .map((e) => Ride.fromJson(e as Map<String, dynamic>))
      .toList(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$RideResponseToJson(RideResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'message': instance.message,
    };

RideActionResponse _$RideActionResponseFromJson(Map<String, dynamic> json) =>
    RideActionResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : Ride.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RideActionResponseToJson(RideActionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

RideHistoryResponse _$RideHistoryResponseFromJson(Map<String, dynamic> json) =>
    RideHistoryResponse(
      success: json['success'] as bool,
      rides: (json['rides'] as List<dynamic>)
          .map((e) => Ride.fromJson(e as Map<String, dynamic>))
          .toList(),
      total_count: (json['total_count'] as num?)?.toInt(),
      current_page: (json['current_page'] as num?)?.toInt(),
      total_pages: (json['total_pages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RideHistoryResponseToJson(
  RideHistoryResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'rides': instance.rides,
  'total_count': instance.total_count,
  'current_page': instance.current_page,
  'total_pages': instance.total_pages,
};
