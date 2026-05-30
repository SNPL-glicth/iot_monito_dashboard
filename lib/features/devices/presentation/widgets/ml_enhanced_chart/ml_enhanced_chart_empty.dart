import 'package:flutter/material.dart';

import '../../../../../core/theme/chart_style.dart';

/// Estado vacío del chart ML enhanced.
class MlEnhancedChartEmpty extends StatelessWidget {
  const MlEnhancedChartEmpty({
    super.key,
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: ChartStyle.chartContainerDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            SizedBox(height: 12),
            Text(
              'Esperando datos...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
