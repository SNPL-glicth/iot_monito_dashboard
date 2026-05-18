import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Helpers de color e icono para detalle de dispositivo CRM.
class DeviceDetailHelpers {
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.greenAccent;
      case 'offline':
        return Colors.redAccent;
      case 'maintenance':
        return Colors.orangeAccent;
      case 'error':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  static Color sensorAccentColor(String? raw) {
    final t = (raw ?? '').toLowerCase();
    switch (t) {
      case 'temperature':
        return Colors.orangeAccent;
      case 'humidity':
        return Colors.lightBlueAccent;
      case 'air_quality':
        return Colors.tealAccent;
      case 'power':
        return Colors.purpleAccent;
      case 'voltage':
        return Colors.amberAccent;
      default:
        return DashboardColors.sensorIcon;
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
        return Colors.redAccent;
      case 'warning':
        return Colors.orangeAccent;
      case 'info':
        return Colors.lightBlueAccent;
      default:
        return Colors.blueGrey;
    }
  }
}
