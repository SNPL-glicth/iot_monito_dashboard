import 'package:flutter/material.dart';

/// Leyenda del candlestick chart.
class CandlestickChartLegend extends StatelessWidget {
  const CandlestickChartLegend({
    super.key,
    required this.showHighlighted,
  });

  final bool showHighlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(const Color(0xFF00E676), 'Normal'),
          const SizedBox(width: 16),
          _LegendItem(Colors.orangeAccent, 'Advertencia'),
          const SizedBox(width: 16),
          _LegendItem(Colors.redAccent, 'Alerta'),
          if (showHighlighted) ...[
            const SizedBox(width: 16),
            _LegendItem(Colors.yellowAccent, 'Resaltado'),
          ],
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.color, this.label);

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
