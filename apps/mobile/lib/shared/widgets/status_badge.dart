import 'package:flutter/material.dart';

import '../../features/parcels/data/models/parcel.dart';

class StatusBadge extends StatelessWidget {
  final ParcelStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(compact ? 4 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: compact ? 12 : 16,
            color: colors.foreground,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            status.displayName,
            style: TextStyle(
              color: colors.foreground,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case ParcelStatus.pending:
        return Icons.schedule_outlined;
      case ParcelStatus.infoReceived:
        return Icons.info_outlined;
      case ParcelStatus.inTransit:
        return Icons.local_shipping_outlined;
      case ParcelStatus.outForDelivery:
        return Icons.delivery_dining_outlined;
      case ParcelStatus.delivered:
        return Icons.check_circle_outlined;
      case ParcelStatus.failedAttempt:
        return Icons.error_outline;
      case ParcelStatus.exception:
        return Icons.warning_amber_outlined;
      case ParcelStatus.expired:
        return Icons.timer_off_outlined;
      case ParcelStatus.unknown:
        return Icons.help_outline;
    }
  }

  _StatusColors _getStatusColors(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status) {
      case ParcelStatus.pending:
      case ParcelStatus.infoReceived:
        return _StatusColors(
          background: Colors.grey.shade100,
          foreground: Colors.grey.shade700,
        );
      case ParcelStatus.inTransit:
        return _StatusColors(
          background: Colors.blue.shade50,
          foreground: Colors.blue.shade700,
        );
      case ParcelStatus.outForDelivery:
        return _StatusColors(
          background: Colors.orange.shade50,
          foreground: Colors.orange.shade700,
        );
      case ParcelStatus.delivered:
        return _StatusColors(
          background: Colors.green.shade50,
          foreground: Colors.green.shade700,
        );
      case ParcelStatus.failedAttempt:
      case ParcelStatus.exception:
        return _StatusColors(
          background: Colors.red.shade50,
          foreground: Colors.red.shade700,
        );
      case ParcelStatus.expired:
        return _StatusColors(
          background: Colors.grey.shade200,
          foreground: Colors.grey.shade600,
        );
      case ParcelStatus.unknown:
        return _StatusColors(
          background: colorScheme.surfaceContainerHighest,
          foreground: colorScheme.onSurfaceVariant,
        );
    }
  }
}

class _StatusColors {
  final Color background;
  final Color foreground;

  const _StatusColors({
    required this.background,
    required this.foreground,
  });
}
