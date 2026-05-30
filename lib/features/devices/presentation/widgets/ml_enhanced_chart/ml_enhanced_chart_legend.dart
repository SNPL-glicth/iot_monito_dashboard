import 'package:flutter/material.dart';

import '../../../../../core/theme/chart_style.dart';
import '../ml_enhanced_chart_painters.dart';

/// Leyenda del chart ML enhanced.
class MlEnhancedChartLegend extends StatelessWidget {
  const MlEnhancedChartLegend({
    super.key,
    required this.showBaseline,
    required this.showConfidenceBand,
  });

  final bool showBaseline;
  final bool showConfidenceBand;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(ChartStyle.valueLineColor, 'Valor real'),
        SizedBox(width: 12),
        if (showBaseline) ...[
          _legendItem(ChartStyle.baselineColor, 'Baseline ML', dashed: true),
          SizedBox(width: 12),
        ],
        if (showConfidenceBand) ...[
          _legendItem(ChartStyle.confidenceBorderColor, 'Confianza', filled: true),
          SizedBox(width: 12),
        ],
        _legendItem(ChartStyle.warningColor, 'Advertencia'),
        SizedBox(width: 12),
        _legendItem(ChartStyle.alertColor, 'Alerta'),
      ],
    );
  }

  Widget _legendItem(Color color, String label, {bool dashed = false, bool filled = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (filled)
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              border: Border.all(color: color, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
          )
        else if (dashed)
          SizedBox(
            width: 16,
            height: 2,
            child: CustomPaint(
              painter: DashedLinePainter(color: color),
            ),
          )
        else
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 1),
            ),
          ),
        SizedBox(width: 4),
        Text(
          label,
          style: ChartStyle.legendStyle,
        ),
      ],
    );
  }
}
