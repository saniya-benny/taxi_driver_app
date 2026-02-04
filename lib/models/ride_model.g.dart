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
      pickup_time: json['pickup_time'] == null
          ? null
          : _dateTimeFromJson(json['pickup_time'] as String?),
      dropoff_time: json['dropoff_time'] == null
          ? null
          : _dateTimeFromJson(json['dropoff_time'] as String?),
      created_at: json['created_at'] == null
          ? null
          : _dateTimeFromJson(json['created_at'] as String?),
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
      'pickup_time': _dateTimeToJson(instance.pickup_time),
      'dropoff_time': _dateTimeToJson(instance.dropoff_time),
      'created_at': _dateTimeToJson(instance.created_at),
    };

Map<String, dynamic> _$RideResponseToJson(RideResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.map((e) => e.toJson()).toList(),
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
      'data': instance.data?.toJson(),
    };

Map<String, dynamic> _$RideHistoryResponseToJson(RideHistoryResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'rides': instance.rides.map((e) => e.toJson()).toList(),
      'total_count': instance.total_count,
      'current_page': instance.current_page,
      'total_pages': instance.total_pages,
    };
