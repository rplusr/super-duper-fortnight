import 'package:equatable/equatable.dart';

import 'tracking_event.dart';

enum CarrierType {
  usps,
  ups,
  fedex,
  dhl,
  dhlExpress,
  amazon,
  royalMail,
  chinaPost,
  yanwen,
  cainiao,
  fourPx,
  sfExpress,
  japanPost,
  koreaPost,
  australiaPost,
  canadaPost,
  laPoste,
  deutschePost,
  postnl,
  chronopost,
  gls,
  dpd,
  hermes,
  evri,
  yodel,
  tnt,
  aramex,
  other;

  static CarrierType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'USPS':
        return CarrierType.usps;
      case 'UPS':
        return CarrierType.ups;
      case 'FEDEX':
        return CarrierType.fedex;
      case 'DHL':
        return CarrierType.dhl;
      case 'DHL_EXPRESS':
        return CarrierType.dhlExpress;
      case 'AMAZON':
        return CarrierType.amazon;
      case 'ROYAL_MAIL':
        return CarrierType.royalMail;
      case 'CHINA_POST':
        return CarrierType.chinaPost;
      case 'YANWEN':
        return CarrierType.yanwen;
      case 'CAINIAO':
        return CarrierType.cainiao;
      case 'FOUR_PX':
      case '4PX':
        return CarrierType.fourPx;
      case 'SF_EXPRESS':
        return CarrierType.sfExpress;
      case 'JAPAN_POST':
        return CarrierType.japanPost;
      case 'KOREA_POST':
        return CarrierType.koreaPost;
      case 'AUSTRALIA_POST':
        return CarrierType.australiaPost;
      case 'CANADA_POST':
        return CarrierType.canadaPost;
      case 'LA_POSTE':
        return CarrierType.laPoste;
      case 'DEUTSCHE_POST':
        return CarrierType.deutschePost;
      case 'POSTNL':
        return CarrierType.postnl;
      case 'CHRONOPOST':
        return CarrierType.chronopost;
      case 'GLS':
        return CarrierType.gls;
      case 'DPD':
        return CarrierType.dpd;
      case 'HERMES':
        return CarrierType.hermes;
      case 'EVRI':
        return CarrierType.evri;
      case 'YODEL':
        return CarrierType.yodel;
      case 'TNT':
        return CarrierType.tnt;
      case 'ARAMEX':
        return CarrierType.aramex;
      default:
        return CarrierType.other;
    }
  }

  String get displayName {
    switch (this) {
      case CarrierType.usps:
        return 'USPS';
      case CarrierType.ups:
        return 'UPS';
      case CarrierType.fedex:
        return 'FedEx';
      case CarrierType.dhl:
        return 'DHL';
      case CarrierType.dhlExpress:
        return 'DHL Express';
      case CarrierType.amazon:
        return 'Amazon';
      case CarrierType.royalMail:
        return 'Royal Mail';
      case CarrierType.chinaPost:
        return 'China Post';
      case CarrierType.yanwen:
        return 'Yanwen';
      case CarrierType.cainiao:
        return 'Cainiao';
      case CarrierType.fourPx:
        return '4PX';
      case CarrierType.sfExpress:
        return 'SF Express';
      case CarrierType.japanPost:
        return 'Japan Post';
      case CarrierType.koreaPost:
        return 'Korea Post';
      case CarrierType.australiaPost:
        return 'Australia Post';
      case CarrierType.canadaPost:
        return 'Canada Post';
      case CarrierType.laPoste:
        return 'La Poste';
      case CarrierType.deutschePost:
        return 'Deutsche Post';
      case CarrierType.postnl:
        return 'PostNL';
      case CarrierType.chronopost:
        return 'Chronopost';
      case CarrierType.gls:
        return 'GLS';
      case CarrierType.dpd:
        return 'DPD';
      case CarrierType.hermes:
        return 'Hermes';
      case CarrierType.evri:
        return 'Evri';
      case CarrierType.yodel:
        return 'Yodel';
      case CarrierType.tnt:
        return 'TNT';
      case CarrierType.aramex:
        return 'Aramex';
      case CarrierType.other:
        return 'Other';
    }
  }

  String get apiValue {
    switch (this) {
      case CarrierType.usps:
        return 'USPS';
      case CarrierType.ups:
        return 'UPS';
      case CarrierType.fedex:
        return 'FEDEX';
      case CarrierType.dhl:
        return 'DHL';
      case CarrierType.dhlExpress:
        return 'DHL_EXPRESS';
      case CarrierType.amazon:
        return 'AMAZON';
      case CarrierType.royalMail:
        return 'ROYAL_MAIL';
      case CarrierType.chinaPost:
        return 'CHINA_POST';
      case CarrierType.yanwen:
        return 'YANWEN';
      case CarrierType.cainiao:
        return 'CAINIAO';
      case CarrierType.fourPx:
        return 'FOUR_PX';
      case CarrierType.sfExpress:
        return 'SF_EXPRESS';
      case CarrierType.japanPost:
        return 'JAPAN_POST';
      case CarrierType.koreaPost:
        return 'KOREA_POST';
      case CarrierType.australiaPost:
        return 'AUSTRALIA_POST';
      case CarrierType.canadaPost:
        return 'CANADA_POST';
      case CarrierType.laPoste:
        return 'LA_POSTE';
      case CarrierType.deutschePost:
        return 'DEUTSCHE_POST';
      case CarrierType.postnl:
        return 'POSTNL';
      case CarrierType.chronopost:
        return 'CHRONOPOST';
      case CarrierType.gls:
        return 'GLS';
      case CarrierType.dpd:
        return 'DPD';
      case CarrierType.hermes:
        return 'HERMES';
      case CarrierType.evri:
        return 'EVRI';
      case CarrierType.yodel:
        return 'YODEL';
      case CarrierType.tnt:
        return 'TNT';
      case CarrierType.aramex:
        return 'ARAMEX';
      case CarrierType.other:
        return 'OTHER';
    }
  }
}

enum ParcelStatus {
  pending,
  infoReceived,
  inTransit,
  outForDelivery,
  delivered,
  failedAttempt,
  exception,
  expired,
  unknown;

  static ParcelStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return ParcelStatus.pending;
      case 'INFO_RECEIVED':
        return ParcelStatus.infoReceived;
      case 'IN_TRANSIT':
        return ParcelStatus.inTransit;
      case 'OUT_FOR_DELIVERY':
        return ParcelStatus.outForDelivery;
      case 'DELIVERED':
        return ParcelStatus.delivered;
      case 'FAILED_ATTEMPT':
        return ParcelStatus.failedAttempt;
      case 'EXCEPTION':
        return ParcelStatus.exception;
      case 'EXPIRED':
        return ParcelStatus.expired;
      default:
        return ParcelStatus.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case ParcelStatus.pending:
        return 'Pending';
      case ParcelStatus.infoReceived:
        return 'Info Received';
      case ParcelStatus.inTransit:
        return 'In Transit';
      case ParcelStatus.outForDelivery:
        return 'Out for Delivery';
      case ParcelStatus.delivered:
        return 'Delivered';
      case ParcelStatus.failedAttempt:
        return 'Failed Attempt';
      case ParcelStatus.exception:
        return 'Exception';
      case ParcelStatus.expired:
        return 'Expired';
      case ParcelStatus.unknown:
        return 'Unknown';
    }
  }

  bool get isActive {
    return this == ParcelStatus.inTransit || this == ParcelStatus.outForDelivery;
  }

  bool get isCompleted {
    return this == ParcelStatus.delivered;
  }

  bool get hasIssue {
    return this == ParcelStatus.failedAttempt ||
           this == ParcelStatus.exception ||
           this == ParcelStatus.expired;
  }
}

class Parcel extends Equatable {
  final String id;
  final String trackingNumber;
  final CarrierType carrier;
  final String? carrierName;
  final String? title;
  final String? description;
  final ParcelStatus status;
  final DateTime? estimatedDelivery;
  final String? originCountry;
  final String? destinationCountry;
  final double? weight;
  final bool notifyOnUpdate;
  final bool notifyOnDelivery;
  final bool isArchived;
  final DateTime? lastSyncAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TrackingEvent> trackingEvents;

  const Parcel({
    required this.id,
    required this.trackingNumber,
    required this.carrier,
    this.carrierName,
    this.title,
    this.description,
    required this.status,
    this.estimatedDelivery,
    this.originCountry,
    this.destinationCountry,
    this.weight,
    this.notifyOnUpdate = true,
    this.notifyOnDelivery = true,
    this.isArchived = false,
    this.lastSyncAt,
    required this.createdAt,
    required this.updatedAt,
    this.trackingEvents = const [],
  });

  factory Parcel.fromJson(Map<String, dynamic> json) {
    return Parcel(
      id: json['id'] as String,
      trackingNumber: json['trackingNumber'] as String,
      carrier: CarrierType.fromString(json['carrier'] as String),
      carrierName: json['carrierName'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: ParcelStatus.fromString(json['status'] as String),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'] as String)
          : null,
      originCountry: json['originCountry'] as String?,
      destinationCountry: json['destinationCountry'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      notifyOnUpdate: json['notifyOnUpdate'] as bool? ?? true,
      notifyOnDelivery: json['notifyOnDelivery'] as bool? ?? true,
      isArchived: json['isArchived'] as bool? ?? false,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      trackingEvents: (json['trackingEvents'] as List<dynamic>?)
              ?.map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  TrackingEvent? get latestEvent =>
      trackingEvents.isNotEmpty ? trackingEvents.first : null;

  String get displayTitle => title ?? trackingNumber;

  String get carrierDisplayName => carrierName ?? carrier.displayName;

  Parcel copyWith({
    String? id,
    String? trackingNumber,
    CarrierType? carrier,
    String? carrierName,
    String? title,
    String? description,
    ParcelStatus? status,
    DateTime? estimatedDelivery,
    String? originCountry,
    String? destinationCountry,
    double? weight,
    bool? notifyOnUpdate,
    bool? notifyOnDelivery,
    bool? isArchived,
    DateTime? lastSyncAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TrackingEvent>? trackingEvents,
  }) {
    return Parcel(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      carrier: carrier ?? this.carrier,
      carrierName: carrierName ?? this.carrierName,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      originCountry: originCountry ?? this.originCountry,
      destinationCountry: destinationCountry ?? this.destinationCountry,
      weight: weight ?? this.weight,
      notifyOnUpdate: notifyOnUpdate ?? this.notifyOnUpdate,
      notifyOnDelivery: notifyOnDelivery ?? this.notifyOnDelivery,
      isArchived: isArchived ?? this.isArchived,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trackingEvents: trackingEvents ?? this.trackingEvents,
    );
  }

  @override
  List<Object?> get props => [
        id,
        trackingNumber,
        carrier,
        status,
        estimatedDelivery,
        isArchived,
        updatedAt,
        trackingEvents,
      ];
}
