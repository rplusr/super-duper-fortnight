import 'package:equatable/equatable.dart';

class ParcelStats extends Equatable {
  final int total;
  final int inTransit;
  final int delivered;
  final int pending;
  final int exception;

  const ParcelStats({
    required this.total,
    required this.inTransit,
    required this.delivered,
    required this.pending,
    required this.exception,
  });

  factory ParcelStats.fromJson(Map<String, dynamic> json) {
    return ParcelStats(
      total: json['total'] as int? ?? 0,
      inTransit: json['inTransit'] as int? ?? 0,
      delivered: json['delivered'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      exception: json['exception'] as int? ?? 0,
    );
  }

  static const empty = ParcelStats(
    total: 0,
    inTransit: 0,
    delivered: 0,
    pending: 0,
    exception: 0,
  );

  @override
  List<Object?> get props => [total, inTransit, delivered, pending, exception];
}
