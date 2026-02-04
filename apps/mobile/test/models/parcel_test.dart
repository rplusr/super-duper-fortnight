import 'package:flutter_test/flutter_test.dart';
import 'package:fashion_boutique/features/parcels/data/models/parcel.dart';
import 'package:fashion_boutique/features/parcels/data/models/tracking_event.dart';

void main() {
  group('CarrierType', () {
    test('fromString converts valid carrier strings', () {
      expect(CarrierType.fromString('USPS'), CarrierType.usps);
      expect(CarrierType.fromString('UPS'), CarrierType.ups);
      expect(CarrierType.fromString('FEDEX'), CarrierType.fedex);
      expect(CarrierType.fromString('DHL'), CarrierType.dhl);
      expect(CarrierType.fromString('DHL_EXPRESS'), CarrierType.dhlExpress);
      expect(CarrierType.fromString('AMAZON'), CarrierType.amazon);
    });

    test('fromString handles case insensitivity', () {
      expect(CarrierType.fromString('usps'), CarrierType.usps);
      expect(CarrierType.fromString('Ups'), CarrierType.ups);
      expect(CarrierType.fromString('fedEx'), CarrierType.fedex);
    });

    test('fromString returns other for unknown carriers', () {
      expect(CarrierType.fromString('UNKNOWN'), CarrierType.other);
      expect(CarrierType.fromString(''), CarrierType.other);
    });

    test('displayName returns human-readable names', () {
      expect(CarrierType.usps.displayName, 'USPS');
      expect(CarrierType.ups.displayName, 'UPS');
      expect(CarrierType.fedex.displayName, 'FedEx');
      expect(CarrierType.dhlExpress.displayName, 'DHL Express');
      expect(CarrierType.amazon.displayName, 'Amazon');
    });

    test('apiValue returns correct API values', () {
      expect(CarrierType.usps.apiValue, 'USPS');
      expect(CarrierType.dhlExpress.apiValue, 'DHL_EXPRESS');
      expect(CarrierType.fourPx.apiValue, 'FOUR_PX');
    });
  });

  group('ParcelStatus', () {
    test('fromString converts valid status strings', () {
      expect(ParcelStatus.fromString('PENDING'), ParcelStatus.pending);
      expect(ParcelStatus.fromString('IN_TRANSIT'), ParcelStatus.inTransit);
      expect(ParcelStatus.fromString('OUT_FOR_DELIVERY'), ParcelStatus.outForDelivery);
      expect(ParcelStatus.fromString('DELIVERED'), ParcelStatus.delivered);
      expect(ParcelStatus.fromString('EXCEPTION'), ParcelStatus.exception);
    });

    test('fromString handles case insensitivity', () {
      expect(ParcelStatus.fromString('pending'), ParcelStatus.pending);
      expect(ParcelStatus.fromString('In_Transit'), ParcelStatus.inTransit);
    });

    test('fromString returns unknown for invalid statuses', () {
      expect(ParcelStatus.fromString('INVALID'), ParcelStatus.unknown);
      expect(ParcelStatus.fromString(''), ParcelStatus.unknown);
    });

    test('displayName returns human-readable names', () {
      expect(ParcelStatus.pending.displayName, 'Pending');
      expect(ParcelStatus.inTransit.displayName, 'In Transit');
      expect(ParcelStatus.outForDelivery.displayName, 'Out for Delivery');
      expect(ParcelStatus.delivered.displayName, 'Delivered');
    });

    test('isActive returns true for active statuses', () {
      expect(ParcelStatus.inTransit.isActive, true);
      expect(ParcelStatus.outForDelivery.isActive, true);
      expect(ParcelStatus.pending.isActive, false);
      expect(ParcelStatus.delivered.isActive, false);
    });

    test('isCompleted returns true only for delivered', () {
      expect(ParcelStatus.delivered.isCompleted, true);
      expect(ParcelStatus.inTransit.isCompleted, false);
      expect(ParcelStatus.pending.isCompleted, false);
    });

    test('hasIssue returns true for problem statuses', () {
      expect(ParcelStatus.failedAttempt.hasIssue, true);
      expect(ParcelStatus.exception.hasIssue, true);
      expect(ParcelStatus.expired.hasIssue, true);
      expect(ParcelStatus.inTransit.hasIssue, false);
      expect(ParcelStatus.delivered.hasIssue, false);
    });
  });

  group('Parcel', () {
    final now = DateTime.now();
    final parcelJson = {
      'id': 'parcel-123',
      'trackingNumber': '1Z999AA10123456784',
      'carrier': 'UPS',
      'carrierName': 'UPS',
      'title': 'Test Package',
      'description': 'A test parcel',
      'status': 'IN_TRANSIT',
      'estimatedDelivery': now.toIso8601String(),
      'originCountry': 'USA',
      'destinationCountry': 'CAN',
      'weight': 2.5,
      'notifyOnUpdate': true,
      'notifyOnDelivery': true,
      'isArchived': false,
      'lastSyncAt': now.toIso8601String(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'trackingEvents': [
        {
          'id': 'event-1',
          'status': 'InTransit',
          'statusCode': 'IT',
          'description': 'Package in transit',
          'location': 'Chicago, IL',
          'city': 'Chicago',
          'country': 'United States',
          'timestamp': now.toIso8601String(),
        }
      ],
    };

    test('fromJson creates parcel from JSON', () {
      final parcel = Parcel.fromJson(parcelJson);

      expect(parcel.id, 'parcel-123');
      expect(parcel.trackingNumber, '1Z999AA10123456784');
      expect(parcel.carrier, CarrierType.ups);
      expect(parcel.carrierName, 'UPS');
      expect(parcel.title, 'Test Package');
      expect(parcel.status, ParcelStatus.inTransit);
      expect(parcel.trackingEvents.length, 1);
    });

    test('fromJson handles null optional fields', () {
      final minimalJson = {
        'id': 'parcel-456',
        'trackingNumber': 'TEST123',
        'carrier': 'OTHER',
        'status': 'PENDING',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final parcel = Parcel.fromJson(minimalJson);

      expect(parcel.id, 'parcel-456');
      expect(parcel.title, isNull);
      expect(parcel.description, isNull);
      expect(parcel.estimatedDelivery, isNull);
      expect(parcel.trackingEvents, isEmpty);
    });

    test('displayTitle returns title or tracking number', () {
      final parcelWithTitle = Parcel.fromJson(parcelJson);
      expect(parcelWithTitle.displayTitle, 'Test Package');

      final parcelWithoutTitle = Parcel.fromJson({
        ...parcelJson,
        'title': null,
      });
      expect(parcelWithoutTitle.displayTitle, '1Z999AA10123456784');
    });

    test('carrierDisplayName returns carrierName or carrier display name', () {
      final parcelWithName = Parcel.fromJson(parcelJson);
      expect(parcelWithName.carrierDisplayName, 'UPS');

      final parcelWithoutName = Parcel.fromJson({
        ...parcelJson,
        'carrierName': null,
      });
      expect(parcelWithoutName.carrierDisplayName, 'UPS');
    });

    test('latestEvent returns first tracking event or null', () {
      final parcelWithEvents = Parcel.fromJson(parcelJson);
      expect(parcelWithEvents.latestEvent, isNotNull);
      expect(parcelWithEvents.latestEvent!.description, 'Package in transit');

      final parcelWithoutEvents = Parcel.fromJson({
        ...parcelJson,
        'trackingEvents': [],
      });
      expect(parcelWithoutEvents.latestEvent, isNull);
    });

    test('copyWith creates a copy with updated fields', () {
      final parcel = Parcel.fromJson(parcelJson);
      final updated = parcel.copyWith(
        title: 'Updated Title',
        status: ParcelStatus.delivered,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.status, ParcelStatus.delivered);
      expect(updated.id, parcel.id);
      expect(updated.trackingNumber, parcel.trackingNumber);
    });

    test('equality works correctly', () {
      final parcel1 = Parcel.fromJson(parcelJson);
      final parcel2 = Parcel.fromJson(parcelJson);

      expect(parcel1, equals(parcel2));
    });
  });

  group('TrackingEvent', () {
    test('fromJson creates event from JSON', () {
      final now = DateTime.now();
      final json = {
        'id': 'event-123',
        'status': 'InTransit',
        'statusCode': 'IT',
        'description': 'Package in transit',
        'location': 'Chicago, IL',
        'city': 'Chicago',
        'country': 'United States',
        'timestamp': now.toIso8601String(),
      };

      final event = TrackingEvent.fromJson(json);

      expect(event.id, 'event-123');
      expect(event.status, 'InTransit');
      expect(event.description, 'Package in transit');
      expect(event.city, 'Chicago');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'event-456',
        'status': 'Delivered',
        'description': 'Delivered',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final event = TrackingEvent.fromJson(json);

      expect(event.location, isNull);
      expect(event.city, isNull);
      expect(event.country, isNull);
    });
  });
}
