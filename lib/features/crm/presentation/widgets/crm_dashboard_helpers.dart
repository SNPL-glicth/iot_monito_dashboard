import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../monitoring/presentation/styles/dashboard_styles.dart';

/// Helpers de formateo y widgets auxiliares para CrmDashboardContent
class CrmDashboardHelpers {
  static String formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final iso = DateTime.tryParse(raw);
    if (iso != null) {
      return DateFormat('dd/MM/yyyy HH:mm').format(iso.toLocal());
    }
    return raw;
  }

  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.redAccent;
      case 'warning':
        return Colors.orangeAccent;
      case 'info':
        return Colors.lightBlueAccent;
      default:
        return Colors.blueGrey;
    }
  }

  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static Widget sectionHeader({required IconData icon, required String title, Color? color}) {
    final accent = color ?? DashboardColors.sectionAccent;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: DashboardTextStyles.sectionHeader),
      ],
    );
  }

  static Widget modernKpiCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ModernCardDecoration.gradient(gradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 24),
              Text(
                label,
                style: DashboardTextStyles.smallLabel.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: DashboardTextStyles.kpiValue),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: DashboardTextStyles.sensorMeta.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  static Widget statusBreakdownCard({
    required String title,
    required IconData icon,
    required Map<String, int> items,
    required Map<String, Color> colorMap,
  }) {
    final entries = items.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = items.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: DashboardColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(title, style: DashboardTextStyles.deviceTitle),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DashboardColors.primaryAccent20,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Total: $total',
                  style: DashboardTextStyles.smallLabel.copyWith(
                    color: DashboardColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const Text('Sin datos', style: DashboardTextStyles.sensorMeta)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entries.map((e) {
                final color = colorMap[e.key.toLowerCase()] ?? DashboardColors.info;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${capitalize(e.key)}: ${e.value}',
                        style: DashboardTextStyles.sensorMeta.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
