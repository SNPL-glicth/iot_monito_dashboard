import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/sensor_type_config.dart';
import 'optimized_realtime_chart/optimized_realtime_chart_empty.dart';
import 'optimized_realtime_chart/optimized_realtime_chart_legend.dart';
import 'optimized_realtime_chart/optimized_realtime_chart_status.dart';
import 'optimized_realtime_chart_models.dart';
import 'optimized_realtime_chart_helpers.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';

/// Parámetros para procesamiento de ventana deslizante en isolate.
class _SlidingWindowParams {
  const _SlidingWindowParams({
    required this.points,
    required this.maxPoints,
  });

  final List<OptimizedDataPoint> points;
  final int maxPoints;
}

int _severityRank(String state) {
  switch (state.toUpperCase()) {
    case 'ALERT':
      return 3;
    case 'WARNING':
      return 2;
    case 'PREDICTION':
      return 1;
    default:
      return 0;
  }
}

List<OptimizedDataPoint> _deduplicateByTimestamp(List<OptimizedDataPoint> sorted) {
  if (sorted.isEmpty) return sorted;

  final result = <OptimizedDataPoint>[];
  OptimizedDataPoint? current = sorted.first;

  for (int i = 1; i < sorted.length; i++) {
    final next = sorted[i];
    final timeDiff = (next.x - current!.x).abs();

    if (timeDiff < 1000) {
      if (_severityRank(next.state) > _severityRank(current.state)) {
        current = next;
      } else if (_severityRank(next.state) == _severityRank(current.state)) {
        if (next.value.abs() > current.value.abs()) {
          current = next;
        }
      }
    } else {
      result.add(current);
      current = next;
    }
  }

  if (current != null) {
    result.add(current);
  }

  return result;
}

List<OptimizedDataPoint> _applySlidingWindowIsolate(_SlidingWindowParams params) {
  final points = params.points;
  final maxPoints = params.maxPoints;

  if (points.isEmpty) return points;

  // PASO 1: Ordenar por timestamp
  final sorted = List<OptimizedDataPoint>.from(points)
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  // PASO 2: DEDUPLICAR timestamps cercanos (< 1 segundo)
  final deduplicated = _deduplicateByTimestamp(sorted);

  if (deduplicated.length <= maxPoints) return deduplicated;

  // PASO 3: Preservar TODOS los puntos especiales (alertas/warnings)
  final specialPoints = deduplicated.where((p) => p.isSpecial).toList();

  // Calcular cuántos puntos normales podemos incluir
  final normalSlots = maxPoints - specialPoints.length;

  if (normalSlots <= 0) {
    return specialPoints.take(maxPoints).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // PASO 4: Downsampling de puntos normales
  final normalPoints = deduplicated.where((p) => !p.isSpecial).toList();
  final step = normalPoints.length / normalSlots;
  final sampledNormal = <OptimizedDataPoint>[];

  for (int i = 0; i < normalSlots && i * step < normalPoints.length; i++) {
    final idx = (i * step).floor().clamp(0, normalPoints.length - 1);
    sampledNormal.add(normalPoints[idx]);
  }

  // Combinar y ordenar
  final result = [...sampledNormal, ...specialPoints]
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  // Asegurar que el último punto esté incluido
  if (result.isNotEmpty && deduplicated.isNotEmpty && result.last != deduplicated.last) {
    if (result.length >= maxPoints) {
      result[result.length - 1] = deduplicated.last;
    } else {
      result.add(deduplicated.last);
    }
  }

  return result;
}

/// Gráfica en tiempo real OPTIMIZADA - 60 FPS sin parpadeo
/// 
/// Arquitectura por capas:
/// 1. CAPA DATOS: Stream de alta frecuencia (valores de serie)
/// 2. CAPA ALERTAS: Stream de baja frecuencia (cache con TTL)
/// 3. CAPA RENDER: RepaintBoundary + shouldRepaint optimizado
/// 
/// Optimizaciones:
/// - Debouncing de 200ms para updates
/// - Cache de alertas con TTL de 2s
/// - Pre-cálculo de coordenadas X
/// - Sin animaciones que causen lag
/// - Separación de rebuilds (datos vs alertas)
class OptimizedRealtimeChart extends StatefulWidget {
  const OptimizedRealtimeChart({
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
    this.isFrozen = false,
    this.onPointTapped,
  });

  final List<OptimizedDataPoint> points;
  final String unit;
  final String? sensorType;
  final double? alertThresholdMin;
  final double? alertThresholdMax;
  final double? warningThresholdMin;
  final double? warningThresholdMax;
  final double height;
  final int maxPoints;
  final bool isFrozen;
  final void Function(OptimizedDataPoint point)? onPointTapped;

  @override
  State<OptimizedRealtimeChart> createState() => _OptimizedRealtimeChartState();
}

class _OptimizedRealtimeChartState extends State<OptimizedRealtimeChart> {
  // Cache de alertas con TTL
  final AlertCache _alertCache = AlertCache();
  
  // Debouncing
  Timer? _debounceTimer;
  List<OptimizedDataPoint>? _pendingPoints;
  List<OptimizedDataPoint> _displayPoints = [];
  
  // Métricas de performance (debug) - se usa internamente para tracking
  // ignore: unused_field
  int _rebuildCount = 0;
  
  // Pre-calculados para evitar recálculos en build
  List<FlSpot> _cachedSpots = [];
  double _cachedMinX = 0;
  double _cachedMaxX = 0;
  double _cachedMinY = 0;
  double _cachedMaxY = 0;
  int _lastPointsHash = 0;
  Color? _cachedLineColor;

  @override
  void initState() {
    super.initState();
    _processPoints(widget.points, immediate: true);
  }

  @override
  void didUpdateWidget(OptimizedRealtimeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Detectar si realmente cambiaron los datos
    final newHash = _computePointsHash(widget.points);
    if (newHash != _lastPointsHash) {
      if (widget.isFrozen) {
        // Modo congelado: update inmediato sin debounce
        _processPoints(widget.points, immediate: true);
      } else {
        // Modo live: debounce de 200ms
        _scheduleUpdate(widget.points);
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  int _computePointsHash(List<OptimizedDataPoint> points) {
    if (points.isEmpty) return 0;
    // Hash rápido basado en primer, último punto y longitud
    final first = points.first;
    final last = points.last;
    return Object.hash(
      points.length,
      first.x,
      first.value,
      last.x,
      last.value,
      last.state,
    );
  }

  void _scheduleUpdate(List<OptimizedDataPoint> points) {
    _pendingPoints = points;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (_pendingPoints != null && mounted) {
        _processPoints(_pendingPoints!, immediate: true);
        _pendingPoints = null;
      }
    });
  }

  Future<void> _processPoints(List<OptimizedDataPoint> points, {bool immediate = false}) async {
    final newHash = _computePointsHash(points);
    if (newHash == _lastPointsHash && !immediate) return;

    _lastPointsHash = newHash;

    // Aplicar ventana deslizante en isolate
    final limited = await compute(
      _applySlidingWindowIsolate,
      _SlidingWindowParams(points: points, maxPoints: widget.maxPoints),
    );
    
    // Pre-calcular spots y bounds
    final spots = <FlSpot>[];
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final p in limited) {
      spots.add(FlSpot(p.x, p.value));
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.value < minY) minY = p.value;
      if (p.value > maxY) maxY = p.value;
    }

    // Ajustar bounds con sensor config
    final sensorConfig = SensorTypeConfigs.getConfig(widget.sensorType);
    final bounds = sensorConfig.adjustChartBounds(minY, maxY);

    // Actualizar cache de alertas si es necesario
    if (!_alertCache.isValid(newHash)) {
      _alertCache.update(limited, newHash);
    }

    // Actualizar estado
    if (mounted) {
      setState(() {
        _displayPoints = limited;
        _cachedSpots = spots;
        _cachedMinX = minX;
        _cachedMaxX = maxX;
        _cachedMinY = bounds.min;
        _cachedMaxY = bounds.max;
        _cachedLineColor = _computeLineColor();
        _rebuildCount++;
      });
    }
  }

  /// Calcula el color de la línea basado en el estado predominante de los puntos.
  /// El estado viene del backend (SSOT), Flutter solo lo renderiza.
  Color _computeLineColor() {
    if (_displayPoints.isEmpty) return const Color(0xFF00E676);
    
    final total = _displayPoints.length;
    final alertCount = _displayPoints.where((p) => p.isAlert).length;
    final warningCount = _displayPoints.where((p) => p.isWarning).length;
    
    // Si >50% son ALERT, línea roja
    if (alertCount > 0 && alertCount >= total * 0.5) {
      return DesignColors.red;
    }
    // Si >50% son WARNING, línea naranja
    if (warningCount > 0 && warningCount >= total * 0.5) {
      return DesignColors.amber;
    }
    // Default: verde
    return const Color(0xFF00E676);
  }

  @override
  Widget build(BuildContext context) {
    if (_displayPoints.isEmpty) {
      return OptimizedRealtimeChartEmpty(height: widget.height);
    }

    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OptimizedRealtimeChartStatus(isFrozen: widget.isFrozen),
          SizedBox(height: 8),
          SizedBox(
            height: widget.height,
            child: _buildChart(),
          ),
          SizedBox(height: 8),
          const OptimizedRealtimeChartLegend(),
        ],
      ),
    );
  }


  Widget _buildChart() {
    if (_cachedSpots.isEmpty) {
      return OptimizedRealtimeChartEmpty(height: widget.height);
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: Colors.white10),
      ),
      padding: EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: LineChart(
        duration: Duration.zero, // Sin animaciones
        LineChartData(
          minX: _cachedMinX,
          maxX: _cachedMaxX,
          minY: _cachedMinY,
          maxY: _cachedMaxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: ((_cachedMaxY - _cachedMinY) / 5).clamp(0.1, double.infinity),
            verticalInterval: ((_cachedMaxX - _cachedMinX) / 6).clamp(1.0, double.infinity),
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
                    return SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(right: 4),
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
                interval: ((_cachedMaxX - _cachedMinX) / 4).clamp(1.0, double.infinity),
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
            LineChartBarData(
              spots: _cachedSpots,
              isCurved: true,
              curveSmoothness: 0.15,
              color: _cachedLineColor ?? const Color(0xFF00E676),
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) {
                  // Siempre mostrar alertas/warnings, ocultar normales si hay muchos
                  if (_alertCache.isAlertAt(spot.x) || _alertCache.isWarningAt(spot.x)) {
                    return true;
                  }
                  return _cachedSpots.length < 100;
                },
                getDotPainter: (spot, percent, barData, index) {
                  // Usar cache para determinar color - O(1) lookup
                  if (_alertCache.isAlertAt(spot.x)) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: DesignColors.red,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  }
                  if (_alertCache.isWarningAt(spot.x)) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: DesignColors.amber,
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
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF2A2F3E),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final dt = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                  final timeStr = DateFormat('HH:mm:ss').format(dt);
                  final valueStr = spot.y.toStringAsFixed(2);
                  
                  // Buscar punto para estado
                  final pointData = _displayPoints.where((p) => 
                    (p.x - spot.x).abs() < 1000
                  ).firstOrNull;
                  
                  final stateStr = pointData?.state ?? 'NORMAL';
                  final color = stateStr.toUpperCase() == 'ALERT' 
                      ? DesignColors.red 
                      : stateStr.toUpperCase() == 'WARNING' 
                          ? DesignColors.amber 
                          : Colors.white;
                  
                  return LineTooltipItem(
                    '$valueStr ${widget.unit}\n$timeStr\n$stateStr',
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
                final pointData = _displayPoints.where((p) => 
                  (p.x - spot.x).abs() < 1000
                ).firstOrNull;
                if (pointData != null && widget.onPointTapped != null) {
                  widget.onPointTapped!(pointData);
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
    
    if (widget.alertThresholdMin != null) {
      lines.add(HorizontalLine(
        y: widget.alertThresholdMin!,
        color: DesignColors.red.withValues(alpha: 0.6),
        strokeWidth: 1.5,
        dashArray: [5, 3],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topLeft,
          style: TextStyle(
            color: DesignColors.red.withValues(alpha: 0.8),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          labelResolver: (_) => 'Alert Min',
        ),
      ));
    }
    
    if (widget.alertThresholdMax != null) {
      lines.add(HorizontalLine(
        y: widget.alertThresholdMax!,
        color: DesignColors.red.withValues(alpha: 0.6),
        strokeWidth: 1.5,
        dashArray: [5, 3],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topLeft,
          style: TextStyle(
            color: DesignColors.red.withValues(alpha: 0.8),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          labelResolver: (_) => 'Alert Max',
        ),
      ));
    }
    
    if (widget.warningThresholdMin != null) {
      lines.add(HorizontalLine(
        y: widget.warningThresholdMin!,
        color: DesignColors.amber.withValues(alpha: 0.5),
        strokeWidth: 1.2,
        dashArray: [4, 4],
      ));
    }
    
    if (widget.warningThresholdMax != null) {
      lines.add(HorizontalLine(
        y: widget.warningThresholdMax!,
        color: DesignColors.amber.withValues(alpha: 0.5),
        strokeWidth: 1.2,
        dashArray: [4, 4],
      ));
    }
    
    return lines;
  }

}
