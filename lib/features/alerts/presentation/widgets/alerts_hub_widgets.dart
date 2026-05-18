import 'package:flutter/material.dart';

import 'alerts_hub_helpers.dart';

/// Widget para mostrar el filtro por sensor activo
class AlertSensorFilter extends StatelessWidget {
  const AlertSensorFilter({
    super.key,
    required this.sensorName,
    required this.onClear,
  });

  final String sensorName;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.tealAccent.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.filter_alt, size: 16, color: Colors.tealAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filtrando: $sensorName',
              style: TextStyle(
                color: Colors.tealAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Ver todas'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.tealAccent,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar el estado vacío de alertas
class AlertEmptyState extends StatelessWidget {
  const AlertEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay alertas activas',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El sistema está funcionando normalmente',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar el resumen de alertas
class AlertSummary extends StatelessWidget {
  const AlertSummary({
    super.key,
    required this.criticalCount,
    required this.warningCount,
    required this.totalCount,
  });

  final int criticalCount;
  final int warningCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black12,
      child: Row(
        children: [
          if (criticalCount > 0) ...[
            AlertCountChip(
              count: criticalCount,
              label: 'Críticas',
              color: Colors.redAccent,
            ),
            const SizedBox(width: 8),
          ],
          if (warningCount > 0)
            AlertCountChip(
              count: warningCount,
              label: 'Advertencias',
              color: Colors.orangeAccent,
            ),
          const Spacer(),
          Text(
            '$totalCount total',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

