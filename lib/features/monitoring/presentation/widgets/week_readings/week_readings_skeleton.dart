import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


class WeekReadingsSkeleton extends StatelessWidget {
  const WeekReadingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(DesignSpacing.lg),
      children: [
        _placeholderBox(width: 180, height: 14),
        SizedBox(height: DesignSpacing.md),
        ...List.generate(7, (_) => _dayCardSkeleton()),
      ],
    );
  }

  Widget _dayCardSkeleton() {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: DesignColors.surface,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _placeholderBox(width: 80, height: 16),
                      const Spacer(),
                      _placeholderBox(width: 40, height: 12),
                    ],
                  ),
                  SizedBox(height: DesignSpacing.sm),
                  _placeholderBox(width: 140, height: 12),
                ],
              ),
            ),
            ...List.generate(3, (_) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  _placeholderBox(width: 20, height: 20, radius: 4),
                  SizedBox(width: DesignSpacing.md),
                  Expanded(
                    child: _placeholderBox(height: 12, radius: 4),
                  ),
                ],
              ),
            )),
            SizedBox(height: DesignSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox({double? width, required double height, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DesignColors.surface2,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
