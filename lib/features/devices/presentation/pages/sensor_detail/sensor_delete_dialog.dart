import 'package:flutter/material.dart';

import '../../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../../monitoring/presentation/styles/dashboard_styles.dart';

/// Dialog for deleting a sensor
class SensorDeleteDialog extends StatelessWidget {
  const SensorDeleteDialog({
    super.key,
    required this.row,
  });

  final DeviceWithSensorViewModel row;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DashboardColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DashboardColors.redAccent15,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.delete_rounded, color: DashboardColors.error, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Eliminar Sensor', style: DashboardTextStyles.deviceTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Está seguro de eliminar el sensor "${row.sensorName ?? 'Sin nombre'}"?',
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DashboardColors.redAccent15,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DashboardColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: DashboardColors.error, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Esta acción no se puede deshacer. Se perderán todos los datos históricos.',
                    style: TextStyle(color: DashboardColors.error, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(foregroundColor: DashboardColors.white70),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DashboardColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}

/// Dialog showing that sensor cannot be deleted
class SensorCannotDeleteDialog extends StatelessWidget {
  const SensorCannotDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DashboardColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DashboardColors.orangeAccent15,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.warning_rounded, color: DashboardColors.warning, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('No se puede eliminar', style: DashboardTextStyles.deviceTitle)),
        ],
      ),
      content: Text(
        'Este sensor está activo y el dispositivo está online.\n\nPara eliminar el sensor, primero desactívelo o espere a que el dispositivo esté offline.',
        style: DashboardTextStyles.sensorMeta,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: DashboardColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}
