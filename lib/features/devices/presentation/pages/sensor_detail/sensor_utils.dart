import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/theme/design_colors.dart';


/// Utility functions for sensor display
class SensorUtils {
  /// Get display label for sensor type
  static String sensorTypeLabel(String? raw) {
    final t = (raw ?? '').toLowerCase();
    switch (t) {
      case 'temperature':
        return 'Temperatura';
      case 'humidity':
        return 'Humedad';
      case 'air_quality':
        return 'Calidad Aire';
      case 'power':
        return 'Potencia';
      case 'voltage':
        return 'Voltaje';
      default:
        return raw ?? '-';
    }
  }

  /// Get accent color for sensor type
  static Color sensorAccentColor(String? raw) {
    final t = (raw ?? '').toLowerCase();
    switch (t) {
      case 'temperature':
        return DesignColors.amber;
      case 'humidity':
        return DesignColors.cyan;
      case 'air_quality':
        return Colors.tealAccent;
      case 'power':
        return Colors.purpleAccent;
      case 'voltage':
        return Colors.amberAccent;
      default:
        return DesignColors.cyan;
    }
  }

  /// Get icon for sensor type
  static IconData sensorIcon(String? raw) {
    final t = (raw ?? '').toLowerCase();
    switch (t) {
      case 'temperature':
        return Icons.thermostat_outlined;
      case 'humidity':
        return Icons.water_drop_outlined;
      case 'air_quality':
        return Icons.air_outlined;
      case 'power':
        return Icons.bolt_outlined;
      case 'voltage':
        return Icons.electrical_services_outlined;
      default:
        return Icons.sensors;
    }
  }

  /// Format datetime string for display
  static String formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final iso = DateTime.tryParse(raw);
    if (iso != null) {
      return DateFormat('dd/MM/yyyy HH:mm').format(iso.toLocal());
    }
    return raw;
  }

  /// Get color for trading state
  static Color tradingStateColor(String raw) {
    switch (raw.toUpperCase()) {
      case 'ALERT':
        return DesignColors.red;
      case 'WARNING':
        return DesignColors.amber;
      default:
        return Colors.tealAccent;
    }
  }
}
