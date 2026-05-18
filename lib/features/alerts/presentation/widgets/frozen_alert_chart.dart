import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/alerts/alert_snapshot_service.dart';
import 'frozen_alert_chart_helpers.dart';
import 'frozen_alert_chart_widgets.dart';
import 'frozen_chart_canvas.dart';

/// Gráfica CONGELADA para detalle de alerta - OPTIMIZADA.
///
/// Características:
/// - Sin Timer ni polling (datos inmutables)
/// - Cache de estados O(1) lookup
/// - Punto trigger resaltado
/// - Umbrales visualizados
/// - RepaintBoundary para evitar rebuilds innecesarios
class FrozenAlertChart extends StatelessWidget {
  const FrozenAlertChart({
    super.key,
    required this.snapshot,
    this.height = 250,
  });

  final AlertSnapshot snapshot;
  final double height;

  static ChartData _computeData(AlertSnapshot snapshot) {
    final cache = FrozenAlertCache();

    if (snapshot.points.isEmpty) {
      return ChartData(
        cache: cache,
        spots: [],
        triggerSpots: [],
        minX: 0,
        maxX: 0,
        minY: 0,
        maxY: 0,
      );
    }

    cache.build(snapshot.points);

    final spots = <FlSpot>[];
    final triggerSpots = <FlSpot>[];

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final p in snapshot.points) {
      final x = p.timestamp.millisecondsSinceEpoch.toDouble();
      final y = p.value;

      spots.add(FlSpot(x, y));

      if (p.isAlertTrigger) {
        triggerSpots.add(FlSpot(x, y));
      }

      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }

    if (snapshot.thresholdMin != null && snapshot.thresholdMin! < minY) {
      minY = snapshot.thresholdMin!;
    }
    if (snapshot.thresholdMax != null && snapshot.thresholdMax! > maxY) {
      maxY = snapshot.thresholdMax!;
    }
    if (snapshot.warningMin != null && snapshot.warningMin! < minY) {
      minY = snapshot.warningMin!;
    }
    if (snapshot.warningMax != null && snapshot.warningMax! > maxY) {
      maxY = snapshot.warningMax!;
    }

    final yPadding = (maxY - minY) * 0.1;
    minY -= yPadding;
    maxY += yPadding;

    if ((maxX - minX).abs() < 1000) {
      final center = (minX + maxX) / 2;
      minX = center - 30000;
      maxX = center + 30000;
    }

    if ((maxY - minY).abs() < 0.1) {
      final center = (minY + maxY) / 2;
      minY = center - 5;
      maxY = center + 5;
    }

    return ChartData(
      cache: cache,
      spots: spots,
      triggerSpots: triggerSpots,
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[FrozenChart] Building with ${snapshot.points.length} points');

    final data = _computeData(snapshot);

    if (snapshot.points.isEmpty || data.spots.isEmpty) {
      debugPrint('[FrozenChart] EMPTY STATE - points=${snapshot.points.length}, cached=${data.spots.length}');
      return FrozenEmptyState(height: height, pointCount: snapshot.points.length);
    }

    final severityColor = snapshot.isCritical
        ? Colors.redAccent
        : (snapshot.isWarning ? Colors.orangeAccent : Colors.tealAccent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FrozenChartHeader(
          severity: snapshot.severity,
          severityColor: severityColor,
        ),
        const SizedBox(height: 12),
        FrozenChartCanvas(
          data: data,
          snapshot: snapshot,
          severityColor: severityColor,
          height: height,
        ),
        const SizedBox(height: 12),
        FrozenTriggerInfo(
          snapshot: snapshot,
          severityColor: severityColor,
        ),
      ],
    );
  }
}
