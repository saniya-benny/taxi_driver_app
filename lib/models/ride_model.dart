import 'package:json_annotation/json_annotation.dart';

part 'ride_model.g.dart';

@JsonSerializable()
class Ride {
  final String id;
  final String? customer_name;
  final String? customer_phone;
  final String? pickup_address;
  final String? dropoff_address;
  final double? pickup_lat;
  final double? pickup_lng;
  final double? dropoff_lat;
  final double? dropoff_lng;
  final double? fare;
  final String? status;
  final String? payment_status;
  
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? pickup_time;
  
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? dropoff_time;
  
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? created_at;

  Ride({
    required this.id,
    this.customer_name,
    this.customer_phone,
    this.pickup_address,
    this.dropoff_address,
    this.pickup_lat,
    this.pickup_lng,
    this.dropoff_lat,
    this.dropoff_lng,
    this.fare,
    this.status,
    this.payment_status,
    this.pickup_time,
    this.dropoff_time,
    this.created_at,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    try {
      return _$RideFromJson(json);
    } catch (e) {
      print('Error parsing Ride from JSON: $e');
      print('JSON data: $json');
      // Return a default ride with minimal data
      return Ride(
        id: json['id']?.toString() ?? 'unknown',
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
    }
  }

  Map<String, dynamic> toJson() => _$RideToJson(this);
  
  // Helper getters for safer access
  String get displayName => customer_name ?? 'Customer';
  String get displayPhone => customer_phone ?? 'No phone';
  String get displayPickupAddress => pickup_address ?? 'Pickup location';
  String get displayDropoffAddress => dropoff_address ?? 'Dropoff location';
  String get displayStatus => status ?? 'Unknown';
  String get displayFare => fare != null ? '₹${fare!.toStringAsFixed(2)}' : '₹0.00';
}

@JsonSerializable()
class RideResponse {
  final bool success;
  final List<Ride> data;
  final String? message;

  RideResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory RideResponse.fromJson(Map<String, dynamic> json) {
    // Handle different response structures
    List<Ride> rides = [];
    
    if (json['data'] != null) {
      if (json['data'] is List) {
        // Direct list in data field
        rides = (json['data'] as List)
            .map((e) => Ride.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (json['data'] is Map && json['data']['rides'] is List) {
        // Nested rides list in data object
        rides = (json['data']['rides'] as List)
            .map((e) => Ride.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else if (json['rides'] is List) {
      // Direct rides field
      rides = (json['rides'] as List)
          .map((e) => Ride.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return RideResponse(
      success: json['success'] ?? false,
      data: rides,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => _$RideResponseToJson(this);
}

@JsonSerializable()
class RideActionResponse {
  final bool success;
  final String? message;
  final Ride? data;

  RideActionResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory RideActionResponse.fromJson(Map<String, dynamic> json) => _$RideActionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RideActionResponseToJson(this);
}

@JsonSerializable()
class RideHistoryResponse {
  final bool success;
  final List<Ride> rides;
  final int? total_count;
  final int? current_page;
  final int? total_pages;

  RideHistoryResponse({
    required this.success,
    required this.rides,
    this.total_count,
    this.current_page,
    this.total_pages,
  });

  factory RideHistoryResponse.fromJson(Map<String, dynamic> json) {
    // Handle different response structures
    List<Ride> rides = [];
    
    if (json['data'] != null) {
      if (json['data'] is List) {
        // Direct list in data field
        rides = (json['data'] as List)
            .map((e) => Ride.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (json['data'] is Map && json['data']['rides'] is List) {
        // Nested rides list in data object
        rides = (json['data']['rides'] as List)
            .map((e) => Ride.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else if (json['rides'] is List) {
      // Direct rides field
      rides = (json['rides'] as List)
          .map((e) => Ride.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return RideHistoryResponse(
      success: json['success'] ?? false,
      rides: rides,
      total_count: json['total_count'],
      current_page: json['current_page'],
      total_pages: json['total_pages'],
    );
  }

  Map<String, dynamic> toJson() => _$RideHistoryResponseToJson(this);
}

DateTime _dateTimeFromJson(String? value) {
  if (value == null || value.isEmpty) return DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
  
  try {
    // Normalize "yyyy-MM-dd HH:mm:ss" → ISO
    final normalized = value.contains(' ')
        ? value.replaceFirst(' ', 'T')
        : value;

    // Treat backend time as UTC
    final utcTime = DateTime.parse(normalized).toUtc();

    // Convert UTC → IST (+05:30)
    return utcTime.add(const Duration(hours: 5, minutes: 30));
  } catch (e) {
    // If parsing fails, return current IST time
    return DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
  }
}

String _dateTimeToJson(DateTime? date) {
  if (date == null) return '';
  // Always send UTC back to backend
  return date.toUtc().toIso8601String();
}
