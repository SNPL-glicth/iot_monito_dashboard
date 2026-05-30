import 'package:flutter/material.dart';
import '../../../../../core/theme/design_spacing.dart';

/// Estado vacío del realtime sensor chart.
class RealtimeSensorChartEmpty extends StatelessWidget {
  const RealtimeSensorChartEmpty({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
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
              'Esperando datos...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'La gráfica se actualizará cuando lleguen lecturas',
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
