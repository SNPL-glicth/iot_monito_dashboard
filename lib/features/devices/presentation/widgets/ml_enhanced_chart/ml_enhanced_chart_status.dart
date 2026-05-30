import 'package:flutter/material.dart';

import '../../../../../core/theme/chart_style.dart';

/// Indicador de estado (vivo/congelado) y confianza ML del chart.
class MlEnhancedChartStatus extends StatelessWidget {
  const MlEnhancedChartStatus({
    super.key,
    required this.isFrozen,
    required this.avgConfidence,
  });

  final bool isFrozen;
  final double avgConfidence;

  @override
  Widget build(BuildContext context) {
    final hasML = avgConfidence > 0;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isFrozen ? Colors.blueAccent : Colors.greenAccent,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(
          isFrozen ? 'CONGELADO' : 'EN VIVO',
          style: TextStyle(
            color: isFrozen ? Colors.blueAccent : Colors.greenAccent,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (hasML) ...[
          Icon(
            Icons.psychology,
            size: 14,
            color: ChartStyle.getConfidenceColor(avgConfidence),
          ),
          SizedBox(width: 4),
          Text(
            'ML ${(avgConfidence * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: ChartStyle.getConfidenceColor(avgConfidence),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
