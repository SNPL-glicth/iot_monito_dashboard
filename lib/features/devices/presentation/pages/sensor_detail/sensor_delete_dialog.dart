import 'package:flutter/material.dart';
import '../../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


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
      backgroundColor: DesignColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.lg)),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignSpacing.sm),
            decoration: BoxDecoration(
              color: DesignColors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Icon(Icons.delete_rounded, color: DesignColors.red, size: 20),
          ),
          SizedBox(width: DesignSpacing.md),
          Text('Eliminar Sensor', style: DesignTextStyles.cardTitle),
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
          SizedBox(height: DesignSpacing.lg),
          Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: DesignColors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              border: Border.all(color: DesignColors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: DesignColors.red, size: 18),
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text(
                    'Esta acción no se puede deshacer. Se perderán todos los datos históricos.',
                    style: TextStyle(color: DesignColors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(foregroundColor: DesignColors.textPrimary),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
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
      backgroundColor: DesignColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.lg)),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignSpacing.sm),
            decoration: BoxDecoration(
              color: DesignColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Icon(Icons.warning_rounded, color: DesignColors.amber, size: 20),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(child: Text('No se puede eliminar', style: DesignTextStyles.cardTitle)),
        ],
      ),
      content: Text(
        'Este sensor está activo y el dispositivo está online.\n\nPara eliminar el sensor, primero desactívelo o espere a que el dispositivo esté offline.',
        style: DesignTextStyles.bodyText,
      ),
      actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.cyan,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
          ),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}
