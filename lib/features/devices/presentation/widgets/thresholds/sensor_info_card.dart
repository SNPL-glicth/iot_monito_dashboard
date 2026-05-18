import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Tarjeta con información básica del sensor.
class SensorInfoCard extends StatelessWidget {
  const SensorInfoCard({
    super.key,
    required this.sensorName,
    required this.sensorType,
    required this.sensorId,
    required this.unit,
  });

  final String sensorName;
  final String sensorType;
  final String sensorId;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.sensors, color: DashboardColors.sensorIcon),
        title: Text(sensorName, style: DashboardTextStyles.deviceTitle),
        subtitle: Text(
          'Tipo: $sensorType · Unidad: ${unit.isEmpty ? '-' : unit}\nSensorId: $sensorId',
          style: DashboardTextStyles.sensorMeta,
        ),
      ),
    );
  }
}
