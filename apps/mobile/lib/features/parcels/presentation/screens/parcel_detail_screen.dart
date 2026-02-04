import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/parcel.dart';
import '../../data/models/tracking_event.dart';
import '../../data/repositories/parcels_repository.dart';
import '../providers/parcels_provider.dart';
import '../widgets/tracking_timeline.dart';

class ParcelDetailScreen extends HookConsumerWidget {
  final String parcelId;

  const ParcelDetailScreen({
    super.key,
    required this.parcelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcelAsync = ref.watch(parcelProvider(parcelId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Details'),
        actions: [
          parcelAsync.maybeWhen(
            data: (parcel) => PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, ref, parcel, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share_outlined),
                    title: Text('Share'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'copy',
                  child: ListTile(
                    leading: Icon(Icons.copy_outlined),
                    title: Text('Copy Tracking #'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: ListTile(
                    leading: Icon(Icons.refresh_outlined),
                    title: Text('Refresh'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outlined, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: parcelAsync.when(
        data: (parcel) => _ParcelDetailContent(parcel: parcel),
        loading: () => const _LoadingContent(),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load parcel details'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(parcelProvider(parcelId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    Parcel parcel,
    String action,
  ) async {
    switch (action) {
      case 'share':
        await Share.share(
          'Track my package:\n'
          '${parcel.displayTitle}\n'
          'Carrier: ${parcel.carrierDisplayName}\n'
          'Tracking: ${parcel.trackingNumber}\n'
          'Status: ${parcel.status.displayName}',
          subject: 'Package Tracking - ${parcel.displayTitle}',
        );
        break;
      case 'copy':
        await Clipboard.setData(ClipboardData(text: parcel.trackingNumber));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tracking number copied')),
          );
        }
        break;
      case 'refresh':
        try {
          await ref.read(parcelsRepositoryProvider).refreshParcel(parcel.id);
          ref.invalidate(parcelProvider(parcelId));
          ref.invalidate(parcelsListProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tracking updated')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to refresh')),
            );
          }
        }
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Parcel'),
            content: const Text('Are you sure you want to delete this parcel?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          try {
            await ref.read(parcelsRepositoryProvider).deleteParcel(parcel.id);
            ref.read(parcelsListProvider.notifier).removeParcel(parcel.id);
            ref.invalidate(parcelStatsProvider);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to delete')),
              );
            }
          }
        }
        break;
    }
  }
}

class _ParcelDetailContent extends StatelessWidget {
  final Parcel parcel;

  const _ParcelDetailContent({required this.parcel});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic would go here
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            parcel.displayTitle,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        StatusBadge(status: parcel.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Carrier',
                      value: parcel.carrierDisplayName,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.tag,
                      label: 'Tracking Number',
                      value: parcel.trackingNumber,
                      monospace: true,
                    ),
                    if (parcel.originCountry != null ||
                        parcel.destinationCountry != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.route_outlined,
                        label: 'Route',
                        value: [
                          parcel.originCountry,
                          parcel.destinationCountry,
                        ].whereType<String>().join(' → '),
                      ),
                    ],
                    if (parcel.lastSyncAt != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.sync_outlined,
                        label: 'Last Updated',
                        value: timeago.format(parcel.lastSyncAt!),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ETA Card
            if (parcel.estimatedDelivery != null && !parcel.status.isCompleted)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_outlined,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Delivery',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                            Text(
                              _formatEta(parcel.estimatedDelivery!),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Progress indicator
            if (parcel.status.isActive)
              Padding(
                padding: const EdgeInsets.all(16),
                child: _ProgressIndicator(status: parcel.status),
              ),

            // Timeline
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracking History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (parcel.trackingEvents.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              size: 48,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tracking updates yet',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    TrackingTimeline(events: parcel.trackingEvents),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatEta(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays > 0 && difference.inDays < 7) {
      return 'In ${difference.inDays} days';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool monospace;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: monospace ? 'monospace' : null,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final ParcelStatus status;

  const _ProgressIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Label Created',
      'Picked Up',
      'In Transit',
      'Out for Delivery',
      'Delivered',
    ];

    final currentStep = _getCurrentStep();

    return Column(
      children: [
        Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              final stepIndex = index ~/ 2;
              return Expanded(
                child: Container(
                  height: 3,
                  color: stepIndex < currentStep
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              );
            }
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep;
            final isCurrent = stepIndex == currentStep;

            return Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isCurrent
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : isCurrent
                      ? Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : null,
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.asMap().entries.map((entry) {
            final isActive = entry.key <= currentStep;
            return SizedBox(
              width: 60,
              child: Text(
                entry.value,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  int _getCurrentStep() {
    switch (status) {
      case ParcelStatus.pending:
      case ParcelStatus.infoReceived:
        return 0;
      case ParcelStatus.inTransit:
        return 2;
      case ParcelStatus.outForDelivery:
        return 3;
      case ParcelStatus.delivered:
        return 4;
      default:
        return 1;
    }
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LoadingSkeleton(width: 180, height: 24),
                      LoadingSkeleton(width: 80, height: 28, borderRadius: 8),
                    ],
                  ),
                  SizedBox(height: 16),
                  LoadingSkeleton(height: 16),
                  SizedBox(height: 8),
                  LoadingSkeleton(height: 16),
                  SizedBox(height: 8),
                  LoadingSkeleton(width: 200, height: 16),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          LoadingSkeleton(width: 120, height: 20),
          SizedBox(height: 16),
          LoadingSkeleton(height: 80),
          SizedBox(height: 12),
          LoadingSkeleton(height: 80),
          SizedBox(height: 12),
          LoadingSkeleton(height: 80),
        ],
      ),
    );
  }
}
