import 'package:flutter/material.dart';

import '../../../monitoring/presentation/styles/dashboard_styles.dart';

/// Widgets helper para AlertDetailPage
class AlertDetailWidgets {
  /// Widget de item de información
  static Widget infoItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Formatea umbral para mostrar
  static String formatThreshold(double? min, double? max, String unit) {
    if (min != null && max != null) {
      return '${min.toStringAsFixed(1)} - ${max.toStringAsFixed(1)} $unit';
    } else if (min != null) {
      return '> ${min.toStringAsFixed(1)} $unit';
    } else if (max != null) {
      return '< ${max.toStringAsFixed(1)} $unit';
    }
    return '-';
  }

  /// Widget de error de carga
  static Widget errorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Error cargando alerta',
              style: DashboardTextStyles.deviceTitle,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: DashboardTextStyles.sensorMeta,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de indicador de estado congelado
  static Widget frozenIndicator() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_clock,
            size: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 4),
          Text(
            'CONGELADO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget de nota sobre estado congelado
  static Widget frozenNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Colors.blueGrey.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta vista muestra el estado exacto al momento de la alerta. '
              'Los datos no se actualizan automáticamente.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
