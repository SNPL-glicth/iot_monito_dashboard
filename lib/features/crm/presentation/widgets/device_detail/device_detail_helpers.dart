import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';


/// Helpers de color e icono para detalle de dispositivo CRM.
class DeviceDetailHelpers {
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.greenAccent;
      case 'offline':
        return DesignColors.red;
      case 'maintenance':
        return DesignColors.amber;
      case 'error':
        return Colors.red;
      default:
        return DesignColors.textSecondary;
    }
  }

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
}
