import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fashion_boutique/shared/widgets/loading_skeleton.dart';

void main() {
  group('LoadingSkeleton', () {
    testWidgets('renders with default dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingSkeleton(),
          ),
        ),
      );

      expect(find.byType(LoadingSkeleton), findsOneWidget);
    });

    testWidgets('renders with custom width and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingSkeleton(width: 200, height: 50),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(LoadingSkeleton),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth, 200);
      expect(container.constraints?.maxHeight, 50);
    });

    testWidgets('renders with custom border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingSkeleton(borderRadius: 16),
          ),
        ),
      );

      expect(find.byType(LoadingSkeleton), findsOneWidget);
    });
  });

  group('ParcelCardSkeleton', () {
    testWidgets('renders loading placeholder for parcel card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParcelCardSkeleton(),
          ),
        ),
      );

      expect(find.byType(ParcelCardSkeleton), findsOneWidget);
      // Should contain multiple skeleton elements
      expect(find.byType(LoadingSkeleton), findsWidgets);
    });
  });

  group('DashboardSkeleton', () {
    testWidgets('renders multiple parcel card skeletons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DashboardSkeleton(),
            ),
          ),
        ),
      );

      expect(find.byType(DashboardSkeleton), findsOneWidget);
      // Should contain multiple parcel card skeletons
      expect(find.byType(ParcelCardSkeleton), findsWidgets);
    });
  });
}
