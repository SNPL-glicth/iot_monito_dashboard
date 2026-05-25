import 'package:flutter/material.dart';

import '../../styles/dashboard_styles.dart';

class WeekReadingsSkeleton extends StatelessWidget {
  const WeekReadingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _placeholderBox(width: 180, height: 14),
        const SizedBox(height: 12),
        ...List.generate(7, (_) => _dayCardSkeleton()),
      ],
    );
  }

  Widget _dayCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: DashboardColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
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
                  const SizedBox(height: 8),
                  _placeholderBox(width: 140, height: 12),
                ],
              ),
            ),
            ...List.generate(3, (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  _placeholderBox(width: 20, height: 20, radius: 4),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _placeholderBox(height: 12, radius: 4),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
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
        color: DashboardColors.surfaceElevated,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
