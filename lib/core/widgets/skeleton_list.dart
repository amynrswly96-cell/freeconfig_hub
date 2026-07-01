import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// نمایش اسکلت بارگذاری (Skeleton Loading) هنگام دریافت لیست سرورها
class SkeletonServerList extends StatelessWidget {
  final int itemCount;
  const SkeletonServerList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1A2338) : Colors.grey.shade200,
      highlightColor: isDark ? const Color(0xFF243154) : Colors.grey.shade100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
