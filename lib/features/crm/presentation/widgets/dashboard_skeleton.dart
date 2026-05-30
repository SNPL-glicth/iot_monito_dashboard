import 'package:flutter/material.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SkeletonLine(width: 220, height: 24),
        SizedBox(height: DesignSpacing.sm),
        const _SkeletonLine(width: 160, height: 14),
        SizedBox(height: DesignSpacing.xl),
        Row(
          children: [
            Expanded(child: _SkeletonCard(height: 90)),
            SizedBox(width: DesignSpacing.md),
            Expanded(child: _SkeletonCard(height: 90)),
          ],
        ),
        SizedBox(height: DesignSpacing.md),
        Row(
          children: [
            Expanded(child: _SkeletonCard(height: 90)),
            SizedBox(width: DesignSpacing.md),
            Expanded(child: _SkeletonCard(height: 90)),
          ],
        ),
        SizedBox(height: DesignSpacing.xl),
        const _SkeletonLine(width: 180, height: 18),
        SizedBox(height: DesignSpacing.md),
        _SkeletonCard(height: 140),
        SizedBox(height: DesignSpacing.xl),
        const _SkeletonLine(width: 140, height: 18),
        SizedBox(height: DesignSpacing.md),
        _SkeletonCard(height: 80),
        SizedBox(height: DesignSpacing.xl),
        const _SkeletonLine(width: 160, height: 18),
        SizedBox(height: DesignSpacing.md),
        _SkeletonCard(height: 80),
        SizedBox(height: DesignSpacing.xxl),
      ],
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DesignColors.surface2,
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: DesignColors.surface,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.border, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonLine(width: 80, height: 12),
            SizedBox(height: DesignSpacing.md),
            _SkeletonLine(width: double.infinity, height: 10),
            SizedBox(height: DesignSpacing.sm),
            _SkeletonLine(width: 140, height: 10),
          ],
        ),
      ),
    );
  }
}
