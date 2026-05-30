import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/intelligence_models.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


/// Helpers de formateo y widgets auxiliares para IntelligenceDecisionsPage
class IntelligenceDecisionsHelpers {
  static String formatLastUpdated(DateTime? lastUpdated) {
    if (lastUpdated == null) return '';
    return 'Actualizado: ${DateFormat('HH:mm:ss').format(lastUpdated)}';
  }

  static String formatAge(int minutes) {
    if (minutes < 60) return 'Hace $minutes min';
    if (minutes < 1440) return 'Hace ${minutes ~/ 60}h';
    return 'Hace ${minutes ~/ 1440}d';
  }

  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return DesignColors.red;
      case 'warning':
        return DesignColors.amber;
      default:
        return DesignColors.cyan;
    }
  }

  static IconData severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.error_rounded;
      case 'warning':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  static String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'acknowledged':
        return 'En proceso';
      case 'resolved':
        return 'Resuelto';
      default:
        return status;
    }
  }

  static IconData statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'acknowledged':
        return Icons.visibility_rounded;
      case 'resolved':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return DesignColors.red;
      case 'acknowledged':
        return DesignColors.amber;
      case 'resolved':
        return DesignColors.green;
      default:
        return DesignColors.cyan;
    }
  }

  static Widget buildFilterChip({
    required String label,
    required String value,
    required List<Map<String, String>> options,
    required ValueChanged<String> onChanged,
  }) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.md)),
      color: DesignColors.surface,
      itemBuilder: (context) => options.map((opt) => PopupMenuItem(
        value: opt['value'],
        child: Text(opt['label']!, style: DesignTextStyles.bodyText),
      )).toList(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: DesignColors.border,
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          border: Border.all(color: DesignColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: DesignTextStyles.timestamp),
                  SizedBox(height: 2),
                  Text(value, style: DesignTextStyles.bodyText),
                ],
              ),
            ),
            Icon(Icons.expand_more_rounded, color: DesignColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  static Widget buildMetaChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 6),
          Text(
            label,
            style: DesignTextStyles.timestamp.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  static Widget buildActionItem(RecommendedActionViewModel action) {
    final priorityColor = action.priority == 1
        ? DesignColors.red
        : action.priority == 2
            ? DesignColors.amber
            : DesignColors.cyan;

    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                '${action.priority}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: priorityColor,
                ),
              ),
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action.action, style: DesignTextStyles.bodyText),
                SizedBox(height: 2),
                Text(
                  action.timeframe.replaceAll('_', ' '),
                  style: DesignTextStyles.timestamp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
