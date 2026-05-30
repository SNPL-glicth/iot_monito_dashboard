import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/chart_data_processor.dart';
import '../../../../core/utils/sensor_type_config.dart';
import 'candlestick_chart/candlestick_chart_empty.dart';
import 'candlestick_chart/candlestick_chart_legend.dart';
import 'candlestick_chart/candlestick_chart_zoom_controls.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';

/// Punto de datos para la gráfica tipo candlestick/IQ Option
class ChartDataPoint {
  ChartDataPoint({
    required this.timestamp,
    required this.value,
    this.state = 'NORMAL',
    this.events = const [],
    this.isHighlighted = false,
  });

  final DateTime timestamp;
  final double value;
  final String state; // NORMAL, WARNING, ALERT
  final List<String> events;
  final bool isHighlighted; // Para resaltar punto desde notificación

  bool get isAlert => state.toUpperCase() == 'ALERT';
  bool get isWarning => state.toUpperCase() == 'WARNING';
  bool get hasDeltaSpike => events.any((e) => e.toUpperCase() == 'DELTA_SPIKE');
  bool get hasAnyEvent => isAlert || isWarning || hasDeltaSpike;
}

/// Gráfica estilo IQ Option / Trading con candlesticks
/// 
/// Características:
/// - Ventana de tiempo fija: última hora
/// - Solo muestra datos cuando hay alertas/advertencias activas
/// - Controles de zoom (lupa)
/// - Diseño moderno con fondo oscuro y grid sutil
/// - Resaltado de puntos de alerta/warning
class CandlestickChart extends StatefulWidget {
  const CandlestickChart({
    super.key,
    required this.points,
    required this.unit,
    this.sensorType,
    this.alertThresholdMin,
    this.alertThresholdMax,
    this.warningThresholdMin,
    this.warningThresholdMax,
    this.highlightTimestamp,
    this.onlyShowWhenAlerts = true,
  });

  final List<ChartDataPoint> points;
  final String unit;
  
  /// Tipo de sensor para escalado dinámico (temperature, humidity, etc.)
  final String? sensorType;
  
  final double? alertThresholdMin;
  final double? alertThresholdMax;
  final double? warningThresholdMin;
  final double? warningThresholdMax;
  
  /// Timestamp específico a resaltar (desde notificación)
  final DateTime? highlightTimestamp;
  
  /// Si es true, solo muestra datos cuando hay alertas/warnings activos
  final bool onlyShowWhenAlerts;

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> 
    with SingleTickerProviderStateMixin {
  
  // Zoom state
  double _zoomLevel = 1.0;
  static const double _minZoom = 0.5;
  static const double _maxZoom = 4.0;
  
  // Pan state
  double _panOffset = 0.0;
  
  // Animation for smooth transitions
  late AnimationController _animController;
  
  // PERF: Cache de datos procesados para evitar recálculos en cada build
  CandlestickProcessedData? _cachedData;
  List<ChartDataPoint>? _lastPoints;
  
  // PERF: Throttle para gestos (evita rebuilds excesivos)
  DateTime _lastGestureUpdate = DateTime.now();
  static const _gestureThrottleMs = 16; // ~60fps
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
  
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
  
  /// Filtra puntos a la última hora
  List<ChartDataPoint> _filterLastHour(List<ChartDataPoint> points) {
    if (points.isEmpty) return [];
    
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    
    return points.where((p) => p.timestamp.isAfter(oneHourAgo)).toList();
  }
  
  /// Verifica si hay alertas/warnings activos en los datos
  bool _hasActiveAlerts(List<ChartDataPoint> points) {
    return points.any((p) => p.hasAnyEvent);
  }
  
  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel * 1.5).clamp(_minZoom, _maxZoom);
    });
  }
  
  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel / 1.5).clamp(_minZoom, _maxZoom);
    });
  }
  
  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
      _panOffset = 0.0;
    });
  }

  /// PERF: Procesa puntos síncronamente con estructura optimizada
  CandlestickProcessedData _processPointsSync(List<ChartDataPoint> points) {
    if (points.isEmpty) {
      return const CandlestickProcessedData(
        mainSpots: [],
        alertSpots: [],
        warningSpots: [],
        highlightSpots: [],
        minT: 0,
        maxT: 0,
        minV: 0,
        maxV: 0,
      );
    }

    final mainSpots = <FlSpot>[];
    final alertSpots = <FlSpot>[];
    final warningSpots = <FlSpot>[];
    final highlightSpots = <FlSpot>[];

    double minT = double.infinity;
    double maxT = double.negativeInfinity;
    double minV = double.infinity;
    double maxV = double.negativeInfinity;

    // FIX CRÍTICO: Solo marcar TRANSICIONES de estado, no cada punto de alerta.
    // Esto evita el efecto "rollo de cinta" con cientos de puntos rojos.
    String? lastState;
    
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = p.timestamp.millisecondsSinceEpoch.toDouble();
      final spot = FlSpot(x, p.value);
      
      mainSpots.add(spot);

      if (x < minT) minT = x;
      if (x > maxT) maxT = x;
      if (p.value < minV) minV = p.value;
      if (p.value > maxV) maxV = p.value;

      // FIX: Detectar si hay transición de estado
      final currentState = p.isAlert ? 'ALERT' : (p.isWarning || p.hasDeltaSpike ? 'WARNING' : 'NORMAL');
      final isTransition = lastState == null || lastState != currentState;
      final isLastPoint = i == points.length - 1;
      
      // Solo marcar puntos en transiciones o el último punto de una serie de alertas
      if (isTransition || isLastPoint) {
        if (p.isAlert) {
          alertSpots.add(spot);
        } else if (p.isWarning || p.hasDeltaSpike) {
          warningSpots.add(spot);
        }
      }
      
      lastState = currentState;

      // Resaltar punto específico (siempre, independiente de transiciones)
      if (widget.highlightTimestamp != null) {
        final diff = p.timestamp.difference(widget.highlightTimestamp!).inSeconds.abs();
        if (diff < 60) {
          highlightSpots.add(spot);
        }
      }
    }

    return CandlestickProcessedData(
      mainSpots: mainSpots,
      alertSpots: alertSpots,
      warningSpots: warningSpots,
      highlightSpots: highlightSpots,
      minT: minT,
      maxT: maxT,
      minV: minV,
      maxV: maxV,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar a última hora
    final hourPoints = _filterLastHour(widget.points);
    
    // Si onlyShowWhenAlerts y no hay alertas, mostrar gráfica vacía
    if (widget.onlyShowWhenAlerts && !_hasActiveAlerts(hourPoints)) {
      return const CandlestickChartEmpty();
    }

    if (hourPoints.isEmpty) {
      return const CandlestickChartEmpty();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CandlestickChartZoomControls(
          zoomLevel: _zoomLevel,
          minZoom: _minZoom,
          maxZoom: _maxZoom,
          onZoomIn: _zoomIn,
          onZoomOut: _zoomOut,
          onReset: _resetZoom,
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 280,
          child: _buildMainChart(hourPoints),
        ),
        CandlestickChartLegend(
          showHighlighted: widget.highlightTimestamp != null,
        ),
      ],
    );
  }
  
  
  Widget _buildMainChart(List<ChartDataPoint> points) {
    // PERF: Verificar si los datos cambiaron para evitar reprocesamiento
    final needsReprocess = _lastPoints == null || 
        _lastPoints!.length != points.length ||
        (_lastPoints!.isNotEmpty && points.isNotEmpty && 
         _lastPoints!.last.timestamp != points.last.timestamp);
    
    if (needsReprocess || _cachedData == null) {
      _lastPoints = points;
      // PERF: Procesar datos síncronamente pero con cache
      // Para datasets grandes, usar ChartDataProcessor.processCandlestickData()
      _cachedData = _processPointsSync(points);
    }
    
    final data = _cachedData!;
    if (data.isEmpty) return const CandlestickChartEmpty();
    
    // FIX CRÍTICO: Usar configuración de tipo de sensor para escalado dinámico
    // Esto evita el efecto "apachurrado" en sensores con rangos diferentes
    final sensorConfig = SensorTypeConfigs.getConfig(widget.sensorType);
    final bounds = sensorConfig.adjustChartBounds(data.minV, data.maxV);
    final adjustedMinV = bounds.min;
    final adjustedMaxV = bounds.max;
    
    // Aplicar zoom
    final tRange = (data.maxT - data.minT) / _zoomLevel;
    final viewMinT = data.maxT - tRange + _panOffset;
    final viewMaxT = data.maxT + _panOffset;
    
    return GestureDetector(
      onScaleUpdate: (details) {
        // PERF: Throttle para evitar rebuilds excesivos (~60fps)
        final now = DateTime.now();
        if (now.difference(_lastGestureUpdate).inMilliseconds < _gestureThrottleMs) {
          return;
        }
        _lastGestureUpdate = now;
        setState(() {
          _zoomLevel = (_zoomLevel * details.scale).clamp(_minZoom, _maxZoom);
        });
      },
      onHorizontalDragUpdate: (details) {
        // PERF: Throttle para pan
        final now = DateTime.now();
        if (now.difference(_lastGestureUpdate).inMilliseconds < _gestureThrottleMs) {
          return;
        }
        _lastGestureUpdate = now;
        setState(() {
          final delta = details.primaryDelta ?? 0;
          _panOffset += delta * 1000 * _zoomLevel;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(color: Colors.white10),
        ),
        padding: EdgeInsets.all(DesignSpacing.md),
        child: LineChart(
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
                color: Colors.white.withValues(alpha: 0.05),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (_) => FlLine(
                color: Colors.white.withValues(alpha: 0.05),
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
                    return Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
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
                    final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Text(
                      DateFormat('HH:mm').format(dt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                // Líneas de umbral de alerta
                if (widget.alertThresholdMin != null)
                  HorizontalLine(
                    y: widget.alertThresholdMin!,
                    color: DesignColors.red.withValues(alpha: 0.6),
                    strokeWidth: 1.5,
                    dashArray: [5, 3],
                  ),
                if (widget.alertThresholdMax != null)
                  HorizontalLine(
                    y: widget.alertThresholdMax!,
                    color: DesignColors.red.withValues(alpha: 0.6),
                    strokeWidth: 1.5,
                    dashArray: [5, 3],
                  ),
                // Líneas de umbral de warning
                if (widget.warningThresholdMin != null)
                  HorizontalLine(
                    y: widget.warningThresholdMin!,
                    color: DesignColors.amber.withValues(alpha: 0.6),
                    strokeWidth: 1.2,
                    dashArray: [4, 4],
                  ),
                if (widget.warningThresholdMax != null)
                  HorizontalLine(
                    y: widget.warningThresholdMax!,
                    color: DesignColors.amber.withValues(alpha: 0.6),
                    strokeWidth: 1.2,
                    dashArray: [4, 4],
                  ),
              ],
            ),
            lineBarsData: [
              // Línea principal (verde/teal)
              LineChartBarData(
                spots: data.mainSpots,
                isCurved: true,
                curveSmoothness: 0.15,
                color: const Color(0xFF00E676), // Verde brillante tipo trading
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF00E676).withValues(alpha: 0.3),
                      const Color(0xFF00E676).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              // Puntos de alerta (rojo)
              if (data.alertSpots.isNotEmpty)
                LineChartBarData(
                  spots: data.alertSpots,
                  isCurved: false,
                  color: Colors.transparent,
                  barWidth: 0,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: DesignColors.red,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                ),
              // Puntos de warning (naranja)
              if (data.warningSpots.isNotEmpty)
                LineChartBarData(
                  spots: data.warningSpots,
                  isCurved: false,
                  color: Colors.transparent,
                  barWidth: 0,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: DesignColors.amber,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                ),
              // Punto resaltado (desde notificación)
              if (data.highlightSpots.isNotEmpty)
                LineChartBarData(
                  spots: data.highlightSpots,
                  isCurved: false,
                  color: Colors.transparent,
                  barWidth: 0,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 10,
                        color: Colors.yellowAccent,
                        strokeWidth: 3,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => const Color(0xFF2D3748),
                // FIX: tooltipRoundedRadius removed in newer fl_chart versions
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final dt = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                    final timeStr = DateFormat('HH:mm:ss').format(dt);
                    final valueStr = '${spot.y.toStringAsFixed(2)} ${widget.unit}';
                    
                    return LineTooltipItem(
                      '$timeStr\n$valueStr',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}
