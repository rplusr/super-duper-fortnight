import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../shared/services/api_service.dart';
import '../../../../shared/services/notification_service.dart';

final _notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

class NotificationPreferencesScreen extends HookConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = useState(true);
    final isLoading = useState(true);
    final hasPermission = useState(false);
    final isSaving = useState(false);

    useEffect(() {
      _loadPreferences(
        context,
        ref,
        notificationsEnabled,
        hasPermission,
        isLoading,
      );
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!hasPermission.value) ...[
                  _PermissionCard(
                    onRequestPermission: () async {
                      final granted =
                          await NotificationService.instance.requestPermission();
                      hasPermission.value = granted;
                      if (granted) {
                        final apiService = ref.read(apiServiceProvider);
                        await NotificationService.instance
                            .registerTokenWithServer(apiService);
                      }
                    },
                  ),
                  const Gap(16),
                ],
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        subtitle: const Text(
                          'Receive notifications about your parcels',
                        ),
                        value: notificationsEnabled.value && hasPermission.value,
                        onChanged: hasPermission.value
                            ? (value) async {
                                isSaving.value = true;
                                try {
                                  final apiService = ref.read(apiServiceProvider);
                                  await apiService.patch(
                                    '/notifications/preferences',
                                    data: {'enabled': value},
                                  );
                                  notificationsEnabled.value = value;
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to update preferences'),
                                      ),
                                    );
                                  }
                                } finally {
                                  isSaving.value = false;
                                }
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                const _SectionHeader(title: 'Notification Types'),
                const Gap(8),
                Card(
                  child: Column(
                    children: [
                      _NotificationTypeItem(
                        icon: Icons.local_shipping_outlined,
                        title: 'Status Updates',
                        subtitle: 'When your parcel status changes',
                        enabled: notificationsEnabled.value && hasPermission.value,
                      ),
                      const Divider(height: 1),
                      _NotificationTypeItem(
                        icon: Icons.check_circle_outline,
                        title: 'Delivery Alerts',
                        subtitle: 'When your parcel is delivered',
                        enabled: notificationsEnabled.value && hasPermission.value,
                      ),
                      const Divider(height: 1),
                      _NotificationTypeItem(
                        icon: Icons.warning_amber_outlined,
                        title: 'Exceptions',
                        subtitle: 'When there is an issue with delivery',
                        enabled: notificationsEnabled.value && hasPermission.value,
                      ),
                    ],
                  ),
                ),
                if (isSaving.value) ...[
                  const Gap(16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
    );
  }

  Future<void> _loadPreferences(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> notificationsEnabled,
    ValueNotifier<bool> hasPermission,
    ValueNotifier<bool> isLoading,
  ) async {
    try {
      // Check notification permission
      hasPermission.value = await NotificationService.instance.hasPermission();

      // Load preferences from server
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/users/me');
      notificationsEnabled.value =
          response.data['notificationsEnabled'] as bool? ?? true;
    } catch (e) {
      // Use defaults on error
    } finally {
      isLoading.value = false;
    }
  }
}

class _PermissionCard extends StatelessWidget {
  final VoidCallback onRequestPermission;

  const _PermissionCard({required this.onRequestPermission});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Notifications Disabled',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Text(
              'Enable notifications to receive updates about your parcels.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const Gap(12),
            FilledButton(
              onPressed: onRequestPermission,
              child: const Text('Enable Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _NotificationTypeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;

  const _NotificationTypeItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).disabledColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? null : Theme.of(context).disabledColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: enabled ? null : Theme.of(context).disabledColor,
        ),
      ),
      trailing: Icon(
        enabled ? Icons.check_circle : Icons.circle_outlined,
        color: enabled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).disabledColor,
      ),
    );
  }
}
