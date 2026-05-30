import 'package:flutter/material.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


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
        SizedBox(height: DesignSpacing.xs),
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
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: DesignColors.red.withValues(alpha: 0.7),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Error cargando alerta',
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

  /// Widget de indicador de estado congelado
  static Widget frozenIndicator() {
    return Container(
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: DesignColors.textSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_clock,
            size: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          SizedBox(width: 4),
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
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(color: DesignColors.textSecondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: DesignColors.textSecondary.withValues(alpha: 0.7),
          ),
          SizedBox(width: DesignSpacing.sm),
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
