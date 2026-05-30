import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../data/models/monitoring_view_models.dart';
import '../../../data/models/reading/raw_reading_models.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';

/// Gráfica de línea con datos crudos de sensor.
class RawSensorChart extends StatelessWidget {
  const RawSensorChart({
    super.key,
    required this.readings,
    required this.unit,
  });

  final List<RawReadingItem> readings;
  final String unit;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(child: Text('Sin datos'));
    }

    final spots = <FlSpot>[];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < readings.length; i++) {
      final r = readings[i];
      spots.add(FlSpot(i.toDouble(), r.value));
      if (r.value < minY) minY = r.value;
      if (r.value > maxY) maxY = r.value;
    }

    final yMargin = (maxY - minY) * 0.1;
    if (yMargin == 0) {
      minY -= 1;
      maxY += 1;
    } else {
      minY -= yMargin;
      maxY += yMargin;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 5,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white12,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(2),
                style: const TextStyle(color: DesignColors.textSecondary, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (readings.length / 5).ceilToDouble().clamp(1, 100),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= readings.length) return SizedBox();
                final ts = readings[idx].timestampFormatted;
                final parts = ts.split(' ');
                final time = parts.length > 1 ? parts[1] : ts;
                return Padding(
                  padding: EdgeInsets.only(top: DesignSpacing.xs),
                  child: Text(
                    time,
                    style: const TextStyle(color: DesignColors.textDim, fontSize: 9),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Colors.cyanAccent,
            barWidth: 2,
            dotData: FlDotData(
              show: readings.length <= 50,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3,
                color: Colors.cyanAccent,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.cyanAccent.withValues(alpha: 0.1),
            ),
          ),
        ],
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.spotIndex;
                if (idx < 0 || idx >= readings.length) return null;
                final r = readings[idx];
                return LineTooltipItem(
                  '${r.value.toStringAsFixed(2)} $unit\n${r.timestampFormatted}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
