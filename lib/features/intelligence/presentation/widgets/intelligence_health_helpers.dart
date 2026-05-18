import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../monitoring/presentation/styles/dashboard_styles.dart';

/// Formatters y helpers de UI para IntelligenceHealthPage
class IntelligenceHealthHelpers {
  static String formatDateTime(String raw) {
    if (raw.isEmpty) return '-';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt.toLocal());
  }

  static String formatPercent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String formatDecimal(double? value) {
    if (value == null) return '-';
    return value.toStringAsFixed(2);
  }

  static LinearGradient getHealthGradient(String health) {
    switch (health) {
      case 'healthy':
        return DashboardColors.gradientSuccess;
      case 'degraded':
        return DashboardColors.gradientWarning;
      case 'critical':
        return const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFC62828)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF757575), Color(0xFF616161)],
        );
    }
  }

  static IconData getHealthIcon(String health) {
    switch (health) {
      case 'healthy':
        return Icons.check_circle_rounded;
      case 'degraded':
        return Icons.warning_rounded;
      case 'critical':
        return Icons.error_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  static Color getPatternColor(String type) {
    switch (type) {
      case 'stable':
        return DashboardColors.success;
      case 'micro_variation':
        return Colors.blueGrey;
      case 'small_change':
        return DashboardColors.info;
      case 'medium_change':
        return DashboardColors.warning;
      case 'spike':
      case 'volatile':
        return DashboardColors.error;
      case 'normal':
        return DashboardColors.primary;
      default:
        return Colors.grey;
    }
  }

  static IconData getPatternIcon(String type) {
    switch (type) {
      case 'stable':
        return Icons.horizontal_rule_rounded;
      case 'micro_variation':
        return Icons.grain_rounded;
      case 'small_change':
        return Icons.trending_flat_rounded;
      case 'medium_change':
        return Icons.show_chart_rounded;
      case 'spike':
      case 'volatile':
        return Icons.flash_on_rounded;
      case 'normal':
        return Icons.auto_graph_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  static String getPatternLabel(String type) {
    switch (type) {
      case 'stable':
        return 'Estable';
      case 'micro_variation':
        return 'Micro-variación';
      case 'small_change':
        return 'Cambio pequeño';
      case 'medium_change':
        return 'Cambio moderado';
      case 'spike':
        return 'Spike';
      case 'volatile':
        return 'Volátil';
      case 'normal':
        return 'Normal';
      default:
        return type;
    }
  }
}
