import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/parcels_provider.dart';
import '../widgets/parcel_card.dart';
import '../widgets/stats_card.dart';

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcelsState = ref.watch(parcelsListProvider);
    final statsAsync = ref.watch(parcelStatsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.name ?? 'there'}!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Track your packages',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(parcelStatsProvider);
          await ref.read(parcelsListProvider.notifier).loadParcels(refresh: true);
        },
        child: CustomScrollView(
          slivers: [
            // Stats Card
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (stats) => StatsCard(stats: stats),
                loading: () => const Card(
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LoadingSkeleton(width: 80, height: 20),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            LoadingSkeleton(width: 60, height: 60),
                            LoadingSkeleton(width: 60, height: 60),
                            LoadingSkeleton(width: 60, height: 60),
                            LoadingSkeleton(width: 60, height: 60),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: parcelsState.statusFilter == null,
                        onSelected: () {
                          ref.read(parcelsListProvider.notifier).setStatusFilter(null);
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'In Transit',
                        isSelected: parcelsState.statusFilter?.name == 'inTransit',
                        onSelected: () {
                          ref.read(parcelsListProvider.notifier).setStatusFilter(
                                parcelsState.statusFilter?.name == 'inTransit'
                                    ? null
                                    : null, // Toggle or add proper filter
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Delivered',
                        isSelected: parcelsState.statusFilter?.name == 'delivered',
                        onSelected: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),

            // Parcel List
            if (parcelsState.isLoading)
              const SliverFillRemaining(
                child: ParcelListSkeleton(),
              )
            else if (parcelsState.parcels.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No Parcels Yet',
                  subtitle: 'Start tracking your packages by adding a tracking number',
                  action: FilledButton.icon(
                    onPressed: () => context.push(Routes.addParcel),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Parcel'),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == parcelsState.parcels.length) {
                      if (parcelsState.hasMore) {
                        ref.read(parcelsListProvider.notifier).loadMore();
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
                    }
                    return ParcelCard(parcel: parcelsState.parcels[index]);
                  },
                  childCount: parcelsState.parcels.length + 1,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.addParcel),
        icon: const Icon(Icons.add),
        label: const Text('Track'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
    );
  }
}
