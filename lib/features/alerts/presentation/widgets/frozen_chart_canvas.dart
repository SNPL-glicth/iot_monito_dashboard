import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/alerts/alert_snapshot_service.dart';
import 'frozen_alert_chart_helpers.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';

/// Canvas del gráfico LineChart para alertas congeladas.
class FrozenChartCanvas extends StatelessWidget {
  const FrozenChartCanvas({
    super.key,
    required this.data,
    required this.snapshot,
    required this.severityColor,
    required this.height,
  });

  final ChartData data;
  final AlertSnapshot snapshot;
  final Color severityColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final spots = data.spots;
    final triggerSpots = data.triggerSpots;
    final minX = data.minX;
    final maxX = data.maxX;
    final minY = data.minY;
    final maxY = data.maxY;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: (maxY - minY) / 5,
            verticalInterval: (maxX - minX) / 6,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 9,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return SizedBox.shrink();
                  }
                  final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: EdgeInsets.only(top: DesignSpacing.xs),
                    child: Text(
                      DateFormat('HH:mm').format(dt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 9,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: _buildThresholdLines(snapshot),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: Colors.tealAccent,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final isTrigger = data.cache.isTriggerAt(spot.x);

                  if (isTrigger) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: severityColor,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  }

                  final pointState = data.cache.getStateAt(spot.x);

                  if (pointState == 'ALERT') {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: DesignColors.red,
                      strokeWidth: 1,
                      strokeColor: DesignColors.textPrimary,
                    );
                  }

                  if (pointState == 'WARNING') {
                    return FlDotCirclePainter(
                      radius: 3,
                      color: DesignColors.amber,
                      strokeWidth: 1,
                      strokeColor: DesignColors.textSecondary,
                    );
                  }

                  return FlDotCirclePainter(
                    radius: 2,
                    color: Colors.tealAccent.withValues(alpha: 0.6),
                    strokeWidth: 0,
                    strokeColor: Colors.transparent,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.tealAccent.withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1E293B),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final dt = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                  bool isTrigger = false;
                  for (final t in triggerSpots) {
                    if ((t.x - spot.x).abs() < 1000) {
                      isTrigger = true;
                      break;
                    }
                  }

                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(2)} ${snapshot.unit}\n'
                    '${DateFormat('HH:mm:ss').format(dt)}\n'
                    '${isTrigger ? '⚠️ TRIGGER' : ''}',
                    TextStyle(
                      color: isTrigger ? severityColor : Colors.white,
                      fontWeight: isTrigger ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<HorizontalLine> _buildThresholdLines(AlertSnapshot snapshot) {
    final lines = <HorizontalLine>[];

    if (snapshot.thresholdMin != null) {
      lines.add(HorizontalLine(
        y: snapshot.thresholdMin!,
        color: DesignColors.red.withValues(alpha: 0.7),
        strokeWidth: 1.5,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          style: const TextStyle(color: DesignColors.red, fontSize: 9),
          labelResolver: (_) => 'Alert Min',
        ),
      ));
    }
    if (snapshot.thresholdMax != null) {
      lines.add(HorizontalLine(
        y: snapshot.thresholdMax!,
        color: DesignColors.red.withValues(alpha: 0.7),
        strokeWidth: 1.5,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          style: const TextStyle(color: DesignColors.red, fontSize: 9),
          labelResolver: (_) => 'Alert Max',
        ),
      ));
    }

    if (snapshot.warningMin != null) {
      lines.add(HorizontalLine(
        y: snapshot.warningMin!,
        color: DesignColors.amber.withValues(alpha: 0.5),
        strokeWidth: 1,
        dashArray: [3, 3],
      ));
    }
    if (snapshot.warningMax != null) {
      lines.add(HorizontalLine(
        y: snapshot.warningMax!,
        color: DesignColors.amber.withValues(alpha: 0.5),
        strokeWidth: 1,
        dashArray: [3, 3],
      ));
    }

    return lines;
  }
}
