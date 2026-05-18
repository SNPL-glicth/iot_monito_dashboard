import 'package:flutter/material.dart';

import '../../styles/dashboard_styles.dart';

/// Helpers compartidos para widgets del dashboard.
class DashboardHelpers {
  DashboardHelpers._();

  /// Traducción de tipos de dispositivo a español.
  static String deviceTypeLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'refrigerator':
        return 'camara frigorifica';
      case 'environmental':
        return 'sensor ambiental';
      case 'energy_meter':
        return 'medidor electrico';
      default:
        return raw;
    }
  }

  /// Color de acento según el tipo de sensor.
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

  /// Icono según el tipo de sensor.
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

  /// Header de sección reutilizable con icono y título.
  static Widget sectionHeader({
    required IconData icon,
    required String title,
    Color? color,
  }) {
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
        Text(
          title,
          style: DashboardTextStyles.sectionHeader,
        ),
      ],
    );
  }
}
