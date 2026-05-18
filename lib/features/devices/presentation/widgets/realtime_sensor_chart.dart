import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/sensor_type_config.dart';
import 'realtime_sensor_chart/realtime_sensor_chart_empty.dart';
import 'realtime_sensor_chart/realtime_sensor_chart_legend.dart';
import 'realtime_sensor_chart/realtime_sensor_chart_status.dart';

/// Punto de datos para la gráfica en tiempo real
class RealtimeDataPoint {
  RealtimeDataPoint({
    required this.timestamp,
    required this.value,
    this.state = 'NORMAL',
    this.events = const [],
  });

  final DateTime timestamp;
  final double value;
  final String state;
  final List<String> events;

  bool get isAlert => state.toUpperCase() == 'ALERT';
  bool get isWarning => state.toUpperCase() == 'WARNING';
  bool get isPrediction => state.toUpperCase() == 'PREDICTION';
  bool get hasDeltaSpike => events.any((e) => e.toUpperCase() == 'DELTA_SPIKE');
}

/// Gráfica en tiempo real - Ventana deslizante viva.
/// 
/// Comportamiento funcional:
/// - Interacción táctil habilitada para consultar puntos
/// - Siempre alineada con la captura actual (100% del rango visible)
/// - El eje X avanza automáticamente con el tiempo
/// - Ventana deslizante con límite máximo de puntos
class RealtimeSensorChart extends StatelessWidget {
  const RealtimeSensorChart({
    super.key,
    required this.points,
    required this.unit,
    this.sensorType,
    this.alertThresholdMin,
    this.alertThresholdMax,
    this.warningThresholdMin,
    this.warningThresholdMax,
    this.height = 280,
    this.maxPoints = 200,
    this.onPointTapped,
  });

  final List<RealtimeDataPoint> points;
  final String unit;
  final String? sensorType;
  final double? alertThresholdMin;
  final double? alertThresholdMax;
  final double? warningThresholdMin;
  final double? warningThresholdMax;
  final double height;
  final int maxPoints;
  final void Function(RealtimeDataPoint point)? onPointTapped;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return RealtimeSensorChartEmpty(height: height);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const RealtimeSensorChartStatus(),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          child: _buildChart(),
        ),
        const SizedBox(height: 8),
        const RealtimeSensorChartLegend(),
      ],
    );
  }


  Widget _buildChart() {
    // FIX Issue 3: Apply sliding window limit to prevent accumulation
    final limitedPoints = _applySlidingWindow(points, maxPoints);
    
    // Process limited points
    final mainSpots = <FlSpot>[];
    final alertSpots = <FlSpot>[];
    final warningSpots = <FlSpot>[];
    
    double minT = double.infinity;
    double maxT = double.negativeInfinity;
    double minV = double.infinity;
    double maxV = double.negativeInfinity;

    for (final p in limitedPoints) {
      final x = p.timestamp.millisecondsSinceEpoch.toDouble();
      final spot = FlSpot(x, p.value);
      
      mainSpots.add(spot);
      
      if (x < minT) minT = x;
      if (x > maxT) maxT = x;
      if (p.value < minV) minV = p.value;
      if (p.value > maxV) maxV = p.value;

      // Categorize special points for visual distinction
      if (p.isAlert) {
        alertSpots.add(spot);
      } else if (p.isWarning || p.hasDeltaSpike) {
        warningSpots.add(spot);
      }
    }

    if (mainSpots.isEmpty) return RealtimeSensorChartEmpty(height: height);

    // Dynamic Y-axis scaling using sensor type config
    final sensorConfig = SensorTypeConfigs.getConfig(sensorType);
    final bounds = sensorConfig.adjustChartBounds(minV, maxV);
    final adjustedMinV = bounds.min;
    final adjustedMaxV = bounds.max;

    // Fixed view: always show 100% of data range (no zoom/pan)
    final viewMinT = minT;
    final viewMaxT = maxT;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: LineChart(
        // FIX Issue 4: Disable animations to prevent micro-flickering
        // Use swapAnimationDuration: Duration.zero for instant updates
        duration: Duration.zero,
        LineChartData(
          minX: viewMinT,
          maxX: viewMaxT,
          minY: adjustedMinV,
          maxY: adjustedMaxV,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: (adjustedMaxV - adjustedMinV) / 5,
            verticalInterval: (viewMaxT - viewMinT) / 6,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white.withValues(alpha: 0.06),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (_) => FlLine(
              color: Colors.white.withValues(alpha: 0.06),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: (viewMaxT - viewMinT) / 4,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('HH:mm').format(dt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: _buildThresholdLines(),
          ),
          lineBarsData: [
            // Main line (all data points)
            LineChartBarData(
              spots: mainSpots,
              isCurved: true,
              curveSmoothness: 0.15,
              color: const Color(0xFF00E676),
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) {
                  // FIX: Always show alert/warning dots, hide normal dots when >100 points
                  final isAlertSpot = alertSpots.any((s) => s.x == spot.x && s.y == spot.y);
                  final isWarningSpot = warningSpots.any((s) => s.x == spot.x && s.y == spot.y);
                  
                  // Always show critical points
                  if (isAlertSpot || isWarningSpot) return true;
                  
                  // Hide normal dots when too many points for performance
                  return mainSpots.length < 100;
                },
                getDotPainter: (spot, percent, barData, index) {
                  // Visual distinction by state
                  final isAlertSpot = alertSpots.any((s) => s.x == spot.x && s.y == spot.y);
                  final isWarningSpot = warningSpots.any((s) => s.x == spot.x && s.y == spot.y);
                  
                  if (isAlertSpot) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: Colors.redAccent,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  } else if (isWarningSpot) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: Colors.orangeAccent,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  }
                  
                  return FlDotCirclePainter(
                    radius: 2,
                    color: const Color(0xFF00E676).withValues(alpha: 0.6),
                    strokeWidth: 0,
                    strokeColor: Colors.transparent,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF00E676).withValues(alpha: 0.25),
                    const Color(0xFF00E676).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          // FIX: Enable touch interactions for point inspection
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF2A2F3E),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final dt = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                  final timeStr = DateFormat('HH:mm:ss').format(dt);
                  final valueStr = spot.y.toStringAsFixed(2);
                  
                  // Find the point to get state info
                  final pointData = limitedPoints.where((p) => 
                    p.timestamp.millisecondsSinceEpoch == spot.x.toInt()
                  ).firstOrNull;
                  
                  final stateStr = pointData?.state ?? 'NORMAL';
                  final color = stateStr.toUpperCase() == 'ALERT' 
                      ? Colors.redAccent 
                      : stateStr.toUpperCase() == 'WARNING' 
                          ? Colors.orangeAccent 
                          : Colors.white;
                  
                  return LineTooltipItem(
                    '$valueStr $unit\n$timeStr\n$stateStr',
                    TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
            touchCallback: (event, response) {
              if (event is FlTapUpEvent && response?.lineBarSpots != null) {
                final spot = response!.lineBarSpots!.first;
                final pointData = limitedPoints.where((p) => 
                  p.timestamp.millisecondsSinceEpoch == spot.x.toInt()
                ).firstOrNull;
                if (pointData != null && onPointTapped != null) {
                  onPointTapped!(pointData);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  List<HorizontalLine> _buildThresholdLines() {
    final lines = <HorizontalLine>[];
    
    if (alertThresholdMin != null) {
      lines.add(HorizontalLine(
        y: alertThresholdMin!,
        color: Colors.redAccent.withValues(alpha: 0.6),
        strokeWidth: 1.5,
        dashArray: [5, 3],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topLeft,
          style: TextStyle(
            color: Colors.redAccent.withValues(alpha: 0.8),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          labelResolver: (_) => 'Alert Min',
        ),
      ));
    }
    
    if (alertThresholdMax != null) {
      lines.add(HorizontalLine(
        y: alertThresholdMax!,
        color: Colors.redAccent.withValues(alpha: 0.6),
        strokeWidth: 1.5,
        dashArray: [5, 3],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topLeft,
          style: TextStyle(
            color: Colors.redAccent.withValues(alpha: 0.8),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          labelResolver: (_) => 'Alert Max',
        ),
      ));
    }
    
    if (warningThresholdMin != null) {
      lines.add(HorizontalLine(
        y: warningThresholdMin!,
        color: Colors.orangeAccent.withValues(alpha: 0.5),
        strokeWidth: 1.2,
        dashArray: [4, 4],
      ));
    }
    
    if (warningThresholdMax != null) {
      lines.add(HorizontalLine(
        y: warningThresholdMax!,
        color: Colors.orangeAccent.withValues(alpha: 0.5),
        strokeWidth: 1.2,
        dashArray: [4, 4],
      ));
    }
    
    return lines;
  }


  /// FIX Issue 3: Aplica ventana deslizante con límite máximo de puntos.
  /// Usa downsampling simple para mantener distribución temporal uniforme.
  static List<RealtimeDataPoint> _applySlidingWindow(
    List<RealtimeDataPoint> points,
    int maxPoints,
  ) {
    if (points.length <= maxPoints) return points;

    // Ordenar por timestamp
    final sorted = List<RealtimeDataPoint>.from(points)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Downsampling simple: tomar puntos equidistantes
    final step = sorted.length / maxPoints;
    final result = <RealtimeDataPoint>[];
    
    for (int i = 0; i < maxPoints; i++) {
      final idx = (i * step).floor().clamp(0, sorted.length - 1);
      result.add(sorted[idx]);
    }
    
    // Siempre incluir el último punto (más reciente)
    if (result.last != sorted.last) {
      result[result.length - 1] = sorted.last;
    }
    
    return result;
  }
}
