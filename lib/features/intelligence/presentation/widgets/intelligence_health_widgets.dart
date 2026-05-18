import 'package:flutter/material.dart';

import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import 'intelligence_health_helpers.dart';

/// Widgets auxiliares reutilizables para IntelligenceHealthPage
class IntelligenceHealthWidgets {
  static Widget sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: DashboardTextStyles.deviceTitle),
      ],
    );
  }

  static Widget miniMetric(String label, String value, IconData icon, {Color? color}) {
    final c = color ?? DashboardColors.primary;
    return Column(
      children: [
        Icon(icon, color: c, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: DashboardTextStyles.kpiValue.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: DashboardTextStyles.sensorMeta.copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget errorMetricTile(String acronym, String value, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                acronym,
                style: DashboardTextStyles.smallLabel.copyWith(
                  color: DashboardColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(value, style: DashboardTextStyles.kpiValue.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: DashboardTextStyles.sensorMeta.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  static Widget confidenceBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: DashboardTextStyles.sensorMeta),
            Text(IntelligenceHealthHelpers.formatPercent(value * 100), style: DashboardTextStyles.smallLabel),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  static Widget qualityChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: DashboardTextStyles.kpiValue.copyWith(fontSize: 16, color: color)),
          const SizedBox(height: 2),
          Text(label, style: DashboardTextStyles.sensorMeta.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  static Widget accuracyBar(String threshold, double percent, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(threshold, style: DashboardTextStyles.smallLabel),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            IntelligenceHealthHelpers.formatPercent(percent),
            style: DashboardTextStyles.smallLabel,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  static Widget errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DashboardColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.cloud_off_rounded, color: DashboardColors.error, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar diagnóstico',
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

  static Widget emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.analytics_outlined, color: Colors.grey, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin datos de diagnóstico',
              style: DashboardTextStyles.deviceTitle,
            ),
            const SizedBox(height: 8),
            const Text(
              'El modelo ML aún no ha generado suficientes predicciones para calcular métricas.',
              style: DashboardTextStyles.sensorMeta,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
