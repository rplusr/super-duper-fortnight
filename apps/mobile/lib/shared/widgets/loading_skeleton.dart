import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const LoadingSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ParcelCardSkeleton extends StatelessWidget {
  const ParcelCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const LoadingSkeleton(width: 120, height: 20),
                LoadingSkeleton(
                  width: 80,
                  height: 24,
                  borderRadius: 8,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const LoadingSkeleton(width: 180, height: 14),
            const SizedBox(height: 8),
            const LoadingSkeleton(width: 140, height: 14),
            const SizedBox(height: 12),
            Row(
              children: [
                LoadingSkeleton(
                  width: 24,
                  height: 24,
                  borderRadius: 12,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: LoadingSkeleton(height: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ParcelListSkeleton extends StatelessWidget {
  final int itemCount;

  const ParcelListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ParcelCardSkeleton(),
    );
  }
}
