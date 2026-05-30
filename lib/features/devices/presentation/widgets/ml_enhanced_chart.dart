import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/chart_style.dart';
import '../../../../core/utils/sensor_type_config.dart';
import 'ml_enhanced_chart/ml_enhanced_chart_empty.dart';
import 'ml_enhanced_chart/ml_enhanced_chart_legend.dart';
import 'ml_enhanced_chart/ml_enhanced_chart_status.dart';
import 'ml_enhanced_chart_models.dart';
import '../../../../core/theme/design_spacing.dart';

/// ML Enhanced Chart - Shows value, baseline, and confidence band.
/// 
/// FASE 2.4: This chart visualizes ML features alongside actual values:
/// - Blue line: Actual sensor values
/// - Gray dashed line: ML baseline (expected value)
/// - Green band: Confidence interval (baseline ± 2*std)
/// - Red/Orange dots: Alert/Warning points
/// 
/// This makes the ML observable and explainable to users.
class MLEnhancedChart extends StatefulWidget {
  const MLEnhancedChart({
    super.key,
    required this.points,
    required this.unit,
    this.sensorType,
    this.alertThresholdMin,
    this.alertThresholdMax,
    this.warningThresholdMin,
    this.warningThresholdMax,
    this.height = 320,
    this.maxPoints = 200,
    this.showBaseline = true,
    this.showConfidenceBand = true,
    this.showLegend = true,
    this.isFrozen = false,
    this.onPointTapped,
  });

  final List<MLEnhancedDataPoint> points;
  final String unit;
  final String? sensorType;
  final double? alertThresholdMin;
  final double? alertThresholdMax;
  final double? warningThresholdMin;
  final double? warningThresholdMax;
  final double height;
  final int maxPoints;
  final bool showBaseline;
  final bool showConfidenceBand;
  final bool showLegend;
  final bool isFrozen;
  final void Function(MLEnhancedDataPoint point)? onPointTapped;

  @override
  State<MLEnhancedChart> createState() => _MLEnhancedChartState();
}

class _MLEnhancedChartState extends State<MLEnhancedChart> {
  Timer? _debounceTimer;
  List<MLEnhancedDataPoint> _displayPoints = [];
  
  // Cached chart data
  List<FlSpot>? _valueSpots;
  List<FlSpot>? _baselineSpots;
  List<FlSpot>? _upperBandSpots;
  List<FlSpot>? _lowerBandSpots;
  double _minX = 0, _maxX = 0, _minY = 0, _maxY = 0;
  int _lastHash = 0;

  @override
  void initState() {
    super.initState();
    _processPoints(widget.points, immediate: true);
  }

  @override
  void didUpdateWidget(MLEnhancedChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newHash = _computeHash(widget.points);
    if (newHash != _lastHash) {
      if (widget.isFrozen) {
        _processPoints(widget.points, immediate: true);
      } else {
        _scheduleUpdate(widget.points);
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  int _computeHash(List<MLEnhancedDataPoint> points) {
    if (points.isEmpty) return 0;
    return Object.hash(
      points.length,
      points.first.x,
      points.last.x,
      points.last.value,
      points.last.state,
    );
  }

  void _scheduleUpdate(List<MLEnhancedDataPoint> points) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _processPoints(points, immediate: true);
      }
    });
  }

  void _processPoints(List<MLEnhancedDataPoint> points, {bool immediate = false}) {
    final newHash = _computeHash(points);
    if (newHash == _lastHash && !immediate) return;
    _lastHash = newHash;

    // Apply sliding window
    final limited = _applySlidingWindow(points, widget.maxPoints);
    
    // Pre-calculate spots
    final valueSpots = <FlSpot>[];
    final baselineSpots = <FlSpot>[];
    final upperBandSpots = <FlSpot>[];
    final lowerBandSpots = <FlSpot>[];
    
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;

    for (final p in limited) {
      final x = p.x;
      valueSpots.add(FlSpot(x, p.value));
      
      if (p.hasMLFeatures && widget.showBaseline) {
        baselineSpots.add(FlSpot(x, p.baseline));
        
        if (widget.showConfidenceBand) {
          upperBandSpots.add(FlSpot(x, p.upperBand));
          lowerBandSpots.add(FlSpot(x, p.lowerBand));
        }
      }
      
      // Track bounds
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (p.value < minY) minY = p.value;
      if (p.value > maxY) maxY = p.value;
      
      // Include baseline bounds
      if (p.hasMLFeatures) {
        if (p.upperBand > maxY) maxY = p.upperBand;
        if (p.lowerBand < minY) minY = p.lowerBand;
      }
    }

    // Adjust Y bounds with sensor config
    final sensorConfig = SensorTypeConfigs.getConfig(widget.sensorType);
    final bounds = sensorConfig.adjustChartBounds(minY, maxY);

    if (mounted) {
      setState(() {
        _displayPoints = limited;
        _valueSpots = valueSpots;
        _baselineSpots = baselineSpots;
        _upperBandSpots = upperBandSpots;
        _lowerBandSpots = lowerBandSpots;
        _minX = minX;
        _maxX = maxX;
        _minY = bounds.min;
        _maxY = bounds.max;
      });
    }
  }

  List<MLEnhancedDataPoint> _applySlidingWindow(
    List<MLEnhancedDataPoint> points,
    int maxPoints,
  ) {
    if (points.isEmpty) return points;
    
    final sorted = List<MLEnhancedDataPoint>.from(points)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    if (sorted.length <= maxPoints) return sorted;
    
    // Preserve special points (alerts/warnings)
    final specialPoints = sorted.where((p) => p.isAlert || p.isWarning || p.hasDeltaSpike).toList();
    final normalSlots = maxPoints - specialPoints.length;
    
    if (normalSlots <= 0) {
      return specialPoints.take(maxPoints).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    
    // Downsample normal points
    final normalPoints = sorted.where((p) => !p.isAlert && !p.isWarning && !p.hasDeltaSpike).toList();
    final step = normalPoints.length / normalSlots;
    final sampledNormal = <MLEnhancedDataPoint>[];
    
    for (int i = 0; i < normalSlots && i * step < normalPoints.length; i++) {
      final idx = (i * step).floor().clamp(0, normalPoints.length - 1);
      sampledNormal.add(normalPoints[idx]);
    }
    
    final result = [...sampledNormal, ...specialPoints]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Ensure last point is included
    if (result.isNotEmpty && sorted.isNotEmpty && result.last != sorted.last) {
      if (result.length >= maxPoints) {
        result[result.length - 1] = sorted.last;
      } else {
        result.add(sorted.last);
      }
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_displayPoints.isEmpty) {
      return MlEnhancedChartEmpty(height: widget.height);
    }

    final hasML = _displayPoints.any((p) => p.hasMLFeatures);
    final avgConfidence = hasML
        ? _displayPoints
            .where((p) => p.hasMLFeatures)
            .map((p) => p.confidence)
            .reduce((a, b) => a + b) /
            _displayPoints.where((p) => p.hasMLFeatures).length
        : 0.0;

    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MlEnhancedChartStatus(
            isFrozen: widget.isFrozen,
            avgConfidence: avgConfidence,
          ),
          SizedBox(height: 8),
          SizedBox(
            height: widget.height,
            child: _buildChart(),
          ),
          if (widget.showLegend) ...[
            SizedBox(height: 8),
            MlEnhancedChartLegend(
              showBaseline: widget.showBaseline,
              showConfidenceBand: widget.showConfidenceBand,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChart() {
    final valueSpots = _valueSpots;
    if (valueSpots == null || valueSpots.isEmpty) {
      return MlEnhancedChartEmpty(height: widget.height);
    }

    return Container(
      decoration: ChartStyle.chartContainerDecoration,
      padding: EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: LineChart(
        duration: Duration.zero,
        LineChartData(
          minX: _minX,
          maxX: _maxX,
          minY: _minY,
          maxY: _maxY,
          clipData: const FlClipData.all(),
          gridData: _buildGridData(),
          titlesData: _buildTitlesData(),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: _buildThresholdLines(),
          ),
          lineBarsData: _buildLineBars(),
          lineTouchData: _buildTouchData(),
        ),
      ),
    );
  }

  FlGridData _buildGridData() {
    final yInterval = ((_maxY - _minY) / 5).clamp(0.1, double.infinity);
    final xInterval = ((_maxX - _minX) / 6).clamp(1.0, double.infinity);
    
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: yInterval,
      verticalInterval: xInterval,
      getDrawingHorizontalLine: (_) => FlLine(
        color: ChartStyle.gridColor,
        strokeWidth: ChartStyle.gridLineWidth,
      ),
      getDrawingVerticalLine: (_) => FlLine(
        color: ChartStyle.gridColor,
        strokeWidth: ChartStyle.gridLineWidth,
      ),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
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
                style: ChartStyle.axisLabelStyle,
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: ((_maxX - _minX) / 4).clamp(1.0, double.infinity),
          getTitlesWidget: (value, meta) {
            if (value == meta.min || value == meta.max) {
              return SizedBox.shrink();
            }
            final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
            return Padding(
              padding: EdgeInsets.only(top: DesignSpacing.xs),
              child: Text(
                DateFormat('HH:mm').format(dt),
                style: ChartStyle.axisLabelStyle,
              ),
            );
          },
        ),
      ),
    );
  }

  List<HorizontalLine> _buildThresholdLines() {
    final lines = <HorizontalLine>[];
    
    if (widget.alertThresholdMin != null) {
      lines.add(HorizontalLine(
        y: widget.alertThresholdMin!,
        color: ChartStyle.alertColor.withValues(alpha: 0.6),
        strokeWidth: ChartStyle.thresholdLineWidth,
        dashArray: ChartStyle.thresholdDash,
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topLeft,
          style: TextStyle(
            color: ChartStyle.alertColor.withValues(alpha: 0.8),
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
        color: ChartStyle.alertColor.withValues(alpha: 0.6),
        strokeWidth: ChartStyle.thresholdLineWidth,
        dashArray: ChartStyle.thresholdDash,
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topLeft,
          style: TextStyle(
            color: ChartStyle.alertColor.withValues(alpha: 0.8),
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
        color: ChartStyle.warningColor.withValues(alpha: 0.5),
        strokeWidth: 1.2,
        dashArray: [4, 4],
      ));
    }
    
    if (widget.warningThresholdMax != null) {
      lines.add(HorizontalLine(
        y: widget.warningThresholdMax!,
        color: ChartStyle.warningColor.withValues(alpha: 0.5),
        strokeWidth: 1.2,
        dashArray: [4, 4],
      ));
    }
    
    return lines;
  }

  List<LineChartBarData> _buildLineBars() {
    final bars = <LineChartBarData>[];
    
    // 1. Confidence band (area between upper and lower)
    if (widget.showConfidenceBand && 
        _upperBandSpots != null && 
        _lowerBandSpots != null &&
        _upperBandSpots!.isNotEmpty) {
      // Upper band line (invisible, just for area)
      bars.add(LineChartBarData(
        spots: _upperBandSpots!,
        isCurved: true,
        curveSmoothness: 0.15,
        color: Colors.transparent,
        barWidth: 0,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: ChartStyle.confidenceBandColor,
          cutOffY: _lowerBandSpots!.isNotEmpty 
              ? _lowerBandSpots!.map((s) => s.y).reduce((a, b) => a < b ? a : b)
              : _minY,
          applyCutOffY: true,
        ),
      ));
    }
    
    // 2. Baseline line (gray dashed)
    if (widget.showBaseline && 
        _baselineSpots != null && 
        _baselineSpots!.isNotEmpty) {
      bars.add(LineChartBarData(
        spots: _baselineSpots!,
        isCurved: true,
        curveSmoothness: 0.15,
        color: ChartStyle.baselineColor,
        barWidth: ChartStyle.baselineLineWidth,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        dashArray: ChartStyle.baselineDash,
      ));
    }
    
    // 3. Main value line (blue)
    bars.add(LineChartBarData(
      spots: _valueSpots!,
      isCurved: true,
      curveSmoothness: 0.15,
      color: ChartStyle.valueLineColor,
      barWidth: ChartStyle.valueLineWidth,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, barData) {
          // Always show alert/warning dots
          final point = _displayPoints.where((p) => 
            (p.x - spot.x).abs() < 1000
          ).firstOrNull;
          if (point != null && (point.isAlert || point.isWarning || point.hasDeltaSpike)) {
            return true;
          }
          return _valueSpots!.length < 100;
        },
        getDotPainter: (spot, percent, barData, index) {
          final point = _displayPoints.where((p) => 
            (p.x - spot.x).abs() < 1000
          ).firstOrNull;
          
          if (point != null && point.isAlert) {
            return FlDotCirclePainter(
              radius: ChartStyle.alertDotRadius,
              color: ChartStyle.alertColor,
              strokeWidth: ChartStyle.dotStrokeWidth,
              strokeColor: Colors.white,
            );
          }
          if (point != null && (point.isWarning || point.hasDeltaSpike)) {
            return FlDotCirclePainter(
              radius: ChartStyle.warningDotRadius,
              color: ChartStyle.warningColor,
              strokeWidth: ChartStyle.dotStrokeWidth,
              strokeColor: Colors.white,
            );
          }
          return FlDotCirclePainter(
            radius: ChartStyle.normalDotRadius,
            color: ChartStyle.valueLineColor.withValues(alpha: 0.6),
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
            ChartStyle.valueLineColor.withValues(alpha: 0.15),
            ChartStyle.valueLineColor.withValues(alpha: 0.0),
          ],
        ),
      ),
    ));
    
    return bars;
  }

  LineTouchData _buildTouchData() {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => ChartStyle.tooltipBackground,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final dt = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
            final timeStr = DateFormat('HH:mm:ss').format(dt);
            final valueStr = spot.y.toStringAsFixed(2);
            
            final point = _displayPoints.where((p) => 
              (p.x - spot.x).abs() < 1000
            ).firstOrNull;
            
            final stateStr = point?.state ?? 'NORMAL';
            final color = ChartStyle.getStateColor(stateStr);
            
            // Build tooltip with ML features if available
            final lines = <String>[
              '$valueStr ${widget.unit}',
              timeStr,
              stateStr,
            ];
            
            if (point?.hasMLFeatures == true) {
              final ml = point!.mlFeatures!;
              lines.addAll([
                '',
                'Baseline: ${ml.baseline.toStringAsFixed(2)}',
                'Desviación: ${ml.deviation.toStringAsFixed(2)}',
                'Confianza: ${ml.confidencePercent}',
                'Patrón: ${ml.patternLabel}',
              ]);
            }
            
            return LineTooltipItem(
              lines.join('\n'),
              ChartStyle.tooltipStyle(color: color),
            );
          }).toList();
        },
      ),
      handleBuiltInTouches: true,
      touchCallback: (event, response) {
        if (event is FlTapUpEvent && response?.lineBarSpots != null) {
          final spot = response!.lineBarSpots!.first;
          final point = _displayPoints.where((p) => 
            (p.x - spot.x).abs() < 1000
          ).firstOrNull;
          if (point != null && widget.onPointTapped != null) {
            widget.onPointTapped!(point);
          }
        }
      },
    );
  }

}
