import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../monitoring/presentation/styles/dashboard_styles.dart';

/// Helpers de formateo y widgets auxiliares para DeviceDetailPage
class DeviceDetailHelpers {
  static String formatDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '-';
    final iso = DateTime.tryParse(raw);
    if (iso != null) return DateFormat('dd/MM/yyyy HH:mm').format(iso.toLocal());

    final candidates = <DateFormat>[
      DateFormat('dd/MM/yyyy HH:mm'),
      DateFormat('dd/MM/yyyy HH:mm:ss')
    ];
    for (final f in candidates) {
      try {
        final dt = f.parseLoose(raw);
        return DateFormat('dd/MM/yyyy HH:mm').format(dt);
      } catch (_) {}
    }
    return raw;
  }

  static Color finalStateColor(String finalState) {
    switch (finalState.toLowerCase()) {
      case 'alert':
        return Colors.redAccent;
      case 'warning':
        return Colors.orangeAccent;
      case 'prediction':
        return Colors.purpleAccent;
      default:
        return Colors.blueGrey;
    }
  }

  static String finalStateLabel(String finalState) {
    switch (finalState.toLowerCase()) {
      case 'alert':
        return 'ALERTA';
      case 'warning':
        return 'ADVERTENCIA';
      case 'prediction':
        return 'PREDICCIÓN';
      default:
        return 'NORMAL';
    }
  }

  static String deviceTypeLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'refrigerator':
        return 'refrigeración';
      case 'environmental':
        return 'ambiental';
      case 'energy_meter':
        return 'eléctrico';
      default:
        return raw;
    }
  }

  static (Color, IconData, String) getSensorDisplayInfo(
    String finalState,
    bool isPending,
    bool isActive,
    String deviceStatus,
  ) {
    // Prioridad: estados pendientes > estado del sensor
    if (isPending) {
      switch (deviceStatus) {
        case 'draft':
          return (Colors.blueGrey, Icons.edit_note, 'BORRADOR');
        case 'pending_claim':
          return (Colors.amber, Icons.link, 'PENDIENTE CLAIM');
        case 'pending_confirmation':
          return (Colors.cyan, Icons.verified_outlined, 'PENDIENTE CONFIRMACIÓN');
        case 'pending_activation':
          return (Colors.orange, Icons.hourglass_top, 'PENDIENTE ACTIVACIÓN');
        default:
          return (Colors.blueGrey, Icons.pending, 'PENDIENTE');
      }
    }

    if (!isActive) {
      return (Colors.grey, Icons.sensors_off, 'INACTIVO');
    }

    // Estado normal basado en finalState
    switch (finalState.toLowerCase()) {
      case 'alert':
        return (Colors.redAccent, Icons.sensors, 'ALERTA');
      case 'warning':
        return (Colors.orangeAccent, Icons.sensors, 'ADVERTENCIA');
      case 'prediction':
        return (Colors.purpleAccent, Icons.sensors, 'PREDICCIÓN');
      default:
        return (Colors.tealAccent, Icons.sensors, 'NORMAL');
    }
  }

  static String getPendingActionHint(String deviceStatus) {
    switch (deviceStatus) {
      case 'draft':
        return 'Acción: Activar dispositivo con QR';
      case 'pending_claim':
        return 'Acción: Vincular con firmware';
      case 'pending_confirmation':
        return 'Acción: Confirmar en firmware';
      case 'pending_activation':
        return 'Esperando respuesta del firmware';
      default:
        return 'Completar configuración';
    }
  }

  static Widget modernKpiCard(String label, int value, Color color, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: DashboardTextStyles.sensorMeta),
        ],
      ),
    );
  }
}
