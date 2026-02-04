import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../features/parcels/data/models/parcel.dart';

/// Accessibility helper utilities
class AccessibilityUtils {
  /// Check if accessibility features are enabled
  static bool isAccessibilityEnabled(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.accessibleNavigation ||
        mediaQuery.boldText ||
        mediaQuery.disableAnimations;
  }

  /// Check if reduce motion is enabled
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get scaled text factor
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1);
  }

  /// Check if large fonts are being used
  static bool isLargeText(BuildContext context) {
    return textScaleFactor(context) > 1.3;
  }
}

/// Semantic wrapper for parcel cards
class ParcelCardSemantics extends StatelessWidget {
  final Widget child;
  final String trackingNumber;
  final String carrier;
  final ParcelStatus status;
  final String? estimatedDelivery;
  final VoidCallback? onTap;

  const ParcelCardSemantics({
    super.key,
    required this.child,
    required this.trackingNumber,
    required this.carrier,
    required this.status,
    this.estimatedDelivery,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = _getStatusLabel(status);
    final deliveryInfo = estimatedDelivery != null
        ? 'Estimated delivery: $estimatedDelivery. '
        : '';

    return Semantics(
      button: onTap != null,
      label:
          'Parcel $trackingNumber. Carrier: $carrier. Status: $statusLabel. $deliveryInfo'
          'Double tap to view details.',
      onTap: onTap,
      child: ExcludeSemantics(child: child),
    );
  }

  String _getStatusLabel(ParcelStatus status) {
    switch (status) {
      case ParcelStatus.pending:
        return 'Pending pickup';
      case ParcelStatus.infoReceived:
        return 'Information received';
      case ParcelStatus.inTransit:
        return 'In transit';
      case ParcelStatus.outForDelivery:
        return 'Out for delivery';
      case ParcelStatus.delivered:
        return 'Delivered';
      case ParcelStatus.failedAttempt:
        return 'Delivery attempt failed';
      case ParcelStatus.exception:
        return 'Exception, requires attention';
      case ParcelStatus.expired:
        return 'Tracking expired';
      case ParcelStatus.unknown:
        return 'Unknown status';
    }
  }
}

/// Semantic wrapper for status badges
class StatusBadgeSemantics extends StatelessWidget {
  final Widget child;
  final ParcelStatus status;

  const StatusBadgeSemantics({
    super.key,
    required this.child,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: ${status.displayName}',
      child: ExcludeSemantics(child: child),
    );
  }
}

/// Accessible icon button with proper semantics
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      onTap: onPressed,
      child: IconButton(
        icon: Icon(icon, color: color, size: size),
        onPressed: onPressed,
        tooltip: label,
      ),
    );
  }
}

/// Focus traversal helper for forms
class AccessibleForm extends StatelessWidget {
  final Widget child;
  final bool autofocus;

  const AccessibleForm({
    super.key,
    required this.child,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: child,
    );
  }
}

/// Live region for dynamic announcements
class LiveRegion extends StatelessWidget {
  final Widget child;
  final String? announcement;
  final bool polite;

  const LiveRegion({
    super.key,
    required this.child,
    this.announcement,
    this.polite = true,
  });

  @override
  Widget build(BuildContext context) {
    if (announcement != null) {
      // Announce changes to screen readers
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SemanticsService.announce(
          announcement!,
          TextDirection.ltr,
        );
      });
    }

    return Semantics(
      liveRegion: true,
      child: child,
    );
  }
}
