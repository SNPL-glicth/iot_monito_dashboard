import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_text_styles.dart';
import '../../../../../core/theme/design_colors.dart';


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
        leading: Icon(Icons.sensors, color: DesignColors.cyan),
        title: Text(sensorName, style: DesignTextStyles.cardTitle),
        subtitle: Text(
          'Tipo: $sensorType · Unidad: ${unit.isEmpty ? '-' : unit}\nSensorId: $sensorId',
          style: DesignTextStyles.bodyText,
        ),
      ),
    );
  }
}
