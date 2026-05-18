import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/alerts/alert_snapshot_service.dart';

/// Estado vacío del gráfico
class FrozenEmptyState extends StatelessWidget {
  const FrozenEmptyState({
    super.key,
    required this.height,
    required this.pointCount,
  });

  final double height;
  final int pointCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Sin datos de contexto',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Puntos: $pointCount',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header del gráfico con información del snapshot
class FrozenChartHeader extends StatelessWidget {
  const FrozenChartHeader({
    super.key,
    required this.severity,
    required this.severityColor,
  });

  final String severity;
  final Color severityColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.lock_clock, color: severityColor, size: 16),
        const SizedBox(width: 6),
        Text(
          'Snapshot congelado',
          style: TextStyle(
            color: severityColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: severityColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: severityColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            severity.toUpperCase(),
            style: TextStyle(
              color: severityColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Información del trigger
class FrozenTriggerInfo extends StatelessWidget {
  const FrozenTriggerInfo({
    super.key,
    required this.snapshot,
    required this.severityColor,
  });

  final AlertSnapshot snapshot;
  final Color severityColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: severityColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valor que disparó la alerta',
                  style: TextStyle(
                    color: severityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${snapshot.triggeredValue.toStringAsFixed(2)} ${snapshot.unit}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('dd/MM HH:mm:ss').format(snapshot.triggeredAt),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
