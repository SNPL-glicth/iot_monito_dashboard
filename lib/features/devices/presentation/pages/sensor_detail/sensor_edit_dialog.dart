import 'package:flutter/material.dart';

import '../../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../../monitoring/presentation/styles/dashboard_styles.dart';

/// Dialog for editing sensor name
class SensorEditDialog extends StatelessWidget {
  const SensorEditDialog({
    super.key,
    required this.row,
  });

  final DeviceWithSensorViewModel row;

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController(text: row.sensorName ?? '');

    return AlertDialog(
      backgroundColor: DashboardColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DashboardColors.blueAccent10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.edit_rounded, color: DashboardColors.info, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Editar Sensor', style: DashboardTextStyles.deviceTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nombre del sensor', style: TextStyle(color: DashboardColors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Ingrese el nombre',
              hintStyle: TextStyle(color: DashboardColors.white54),
              filled: true,
              fillColor: DashboardColors.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: DashboardColors.white10)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: DashboardColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DashboardColors.white05,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Tipo: ${row.sensorType ?? '-'} · Unidad: ${row.unit ?? '-'}',
              style: DashboardTextStyles.sensorMeta,
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
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: DashboardColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
