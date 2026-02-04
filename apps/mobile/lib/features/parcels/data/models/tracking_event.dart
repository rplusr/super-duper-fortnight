import 'package:equatable/equatable.dart';

class TrackingEvent extends Equatable {
  final String id;
  final String status;
  final String? statusCode;
  final String description;
  final String? location;
  final String? city;
  final String? country;
  final DateTime timestamp;

  const TrackingEvent({
    required this.id,
    required this.status,
    this.statusCode,
    required this.description,
    this.location,
    this.city,
    this.country,
    required this.timestamp,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      id: json['id'] as String,
      status: json['status'] as String,
      statusCode: json['statusCode'] as String?,
      description: json['description'] as String,
      location: json['location'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String get locationDisplay {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    if (parts.isEmpty && location != null) return location!;
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [id, status, statusCode, description, timestamp];
}
