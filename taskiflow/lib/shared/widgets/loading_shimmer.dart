// ─────────────────────────────────────────────────────────────────────────────
// loading_shimmer.dart
// Skeleton loading menggunakan package shimmer.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final int itemCount;
  const LoadingShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final baseColor    = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor    : baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        physics    : const NeverScrollableScrollPhysics(),
        shrinkWrap : true,
        itemCount  : itemCount,
        itemBuilder: (_, __) => _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin : const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Expanded(child: _Bone(height: 16, width: double.infinity)),
              const SizedBox(width: 12),
              _Bone(height: 22, width: 80),
            ],
          ),
          const SizedBox(height: 10),
          _Bone(height: 12, width: double.infinity),
          const SizedBox(height: 6),
          _Bone(height: 12, width: 200),
          const SizedBox(height: 14),
          _Bone(height: 12, width: 120),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double height;
  final double width;
  const _Bone({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height    : height,
      width     : width,
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
