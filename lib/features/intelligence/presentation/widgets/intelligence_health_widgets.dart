import 'package:flutter/material.dart';
import 'intelligence_health_helpers.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


/// Widgets auxiliares reutilizables para IntelligenceHealthPage
class IntelligenceHealthWidgets {
  static Widget sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(DesignSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: DesignSpacing.md),
        Text(title, style: DesignTextStyles.cardTitle),
      ],
    );
  }

  static Widget miniMetric(String label, String value, IconData icon, {Color? color}) {
    final c = color ?? DesignColors.cyan;
    return Column(
      children: [
        Icon(icon, color: c, size: 24),
        SizedBox(height: DesignSpacing.sm),
        Text(
          value,
          style: DesignTextStyles.kpiValue.copyWith(fontSize: 18),
        ),
        SizedBox(height: DesignSpacing.xs),
        Text(
          label,
          style: DesignTextStyles.bodyText.copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget errorMetricTile(String acronym, String value, String description) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                acronym,
                style: DesignTextStyles.timestamp.copyWith(
                  color: DesignColors.cyanDim,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(value, style: DesignTextStyles.kpiValue.copyWith(fontSize: 16)),
            ],
          ),
          SizedBox(height: DesignSpacing.xs),
          Text(
            description,
            style: DesignTextStyles.bodyText.copyWith(fontSize: 10),
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
            Text(label, style: DesignTextStyles.bodyText),
            Text(IntelligenceHealthHelpers.formatPercent(value * 100), style: DesignTextStyles.timestamp),
          ],
        ),
        SizedBox(height: 6),
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Column(
        children: [
          Text(value, style: DesignTextStyles.kpiValue.copyWith(fontSize: 16, color: color)),
          SizedBox(height: 2),
          Text(label, style: DesignTextStyles.bodyText.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  static Widget accuracyBar(String threshold, double percent, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(threshold, style: DesignTextStyles.timestamp),
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
        SizedBox(width: DesignSpacing.sm),
        SizedBox(
          width: 50,
          child: Text(
            IntelligenceHealthHelpers.formatPercent(percent),
            style: DesignTextStyles.timestamp,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  static Widget errorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                color: DesignColors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DesignRadius.lg),
              ),
              child: Icon(Icons.cloud_off_rounded, color: DesignColors.red, size: 48),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Error al cargar diagnóstico',
              style: DesignTextStyles.cardTitle,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              error,
              style: DesignTextStyles.bodyText,
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
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DesignRadius.lg),
              ),
              child: const Icon(Icons.analytics_outlined, color: Colors.grey, size: 48),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Sin datos de diagnóstico',
              style: DesignTextStyles.cardTitle,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'El modelo ML aún no ha generado suficientes predicciones para calcular métricas.',
              style: DesignTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
