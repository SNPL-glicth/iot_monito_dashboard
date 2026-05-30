import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';
import '../../../../core/theme/design_text_styles.dart';

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
        return DesignColors.red;
      case 'warning':
        return DesignColors.amber;
      case 'info':
        return DesignColors.cyan;
      default:
        return DesignColors.textSecondary;
    }
  }

  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static Widget sectionHeader({required IconData icon, required String title, Color? color}) {
    final accent = color ?? DesignColors.cyan;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(DesignSpacing.sm),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        SizedBox(width: DesignSpacing.md),
        Text(title, style: DesignTextStyles.screenTitle),
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
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: DesignColors.textPrimary.withValues(alpha: 0.9), size: 24),
              Text(
                label,
                style: DesignTextStyles.bodyText.copyWith(
                  color: DesignColors.textPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          Text(value, style: DesignTextStyles.kpiValue),
          SizedBox(height: DesignSpacing.xs),
          Text(
            subtitle,
            style: DesignTextStyles.bodyText.copyWith(
              color: DesignColors.textPrimary.withValues(alpha: 0.8),
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
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.surface,
        border: Border.all(color: DesignColors.border, width: 0.5),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: DesignColors.cyan, size: 20),
              SizedBox(width: DesignSpacing.md),
              Text(title, style: DesignTextStyles.cardTitle),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.xs),
                decoration: BoxDecoration(
                  color: DesignColors.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                ),
                child: Text(
                  'Total: $total',
                  style: DesignTextStyles.badgeText(),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.lg),
          if (entries.isEmpty)
            Text('Sin datos', style: DesignTextStyles.bodyText)
          else
            Wrap(
              spacing: DesignSpacing.sm,
              runSpacing: DesignSpacing.sm,
              children: entries.map((e) {
                final color = colorMap[e.key.toLowerCase()] ?? DesignColors.cyan;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignRadius.xl),
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
                      SizedBox(width: DesignSpacing.sm),
                      Text(
                        '${capitalize(e.key)}: ${e.value}',
                        style: DesignTextStyles.bodyText.copyWith(
                          color: DesignColors.textPrimary,
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
