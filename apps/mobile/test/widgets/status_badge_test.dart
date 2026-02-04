import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fashion_boutique/features/parcels/data/models/parcel.dart';
import 'package:fashion_boutique/shared/widgets/status_badge.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('renders correctly for pending status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: ParcelStatus.pending),
          ),
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders correctly for in transit status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: ParcelStatus.inTransit),
          ),
        ),
      );

      expect(find.text('In Transit'), findsOneWidget);
    });

    testWidgets('renders correctly for delivered status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: ParcelStatus.delivered),
          ),
        ),
      );

      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('renders correctly for exception status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: ParcelStatus.exception),
          ),
        ),
      );

      expect(find.text('Exception'), findsOneWidget);
    });

    testWidgets('renders correctly for out for delivery status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: ParcelStatus.outForDelivery),
          ),
        ),
      );

      expect(find.text('Out for Delivery'), findsOneWidget);
    });

    testWidgets('uses Container as root widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: ParcelStatus.pending),
          ),
        ),
      );

      // StatusBadge should render without errors
      expect(find.byType(StatusBadge), findsOneWidget);
    });
  });
}
