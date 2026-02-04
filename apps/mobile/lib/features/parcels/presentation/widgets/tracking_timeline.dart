import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/tracking_event.dart';

class TrackingTimeline extends StatelessWidget {
  final List<TrackingEvent> events;

  const TrackingTimeline({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isFirst = index == 0;
        final isLast = index == events.length - 1;

        return _TimelineItem(
          event: event,
          isFirst: isFirst,
          isLast: isLast,
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final TrackingEvent event;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.event,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = isFirst
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 48,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                Container(
                  width: isFirst ? 16 : 12,
                  height: isFirst ? 16 : 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFirst
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    border: isFirst
                        ? null
                        : Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 2,
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 24,
                left: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.status,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                          color: isFirst
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (event.locationDisplay.isNotEmpty) ...[
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            event.locationDisplay,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(event.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat.jm().format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat.jm().format(dateTime)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(dateTime);
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }
}
