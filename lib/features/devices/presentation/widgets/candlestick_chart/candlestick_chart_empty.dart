import 'package:flutter/material.dart';
import '../../../../../core/theme/design_spacing.dart';

/// Estado vacío del candlestick chart.
class CandlestickChartEmpty extends StatelessWidget {
  const CandlestickChartEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: Colors.white10),
      ),
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
              'Sin alertas activas',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'La gráfica se mostrará cuando haya alertas o advertencias',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
