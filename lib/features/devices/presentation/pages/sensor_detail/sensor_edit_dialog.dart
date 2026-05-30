import 'package:flutter/material.dart';
import '../../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


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
      backgroundColor: DesignColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.lg)),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignSpacing.sm),
            decoration: BoxDecoration(
              color: DesignColors.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Icon(Icons.edit_rounded, color: DesignColors.cyan, size: 20),
          ),
          SizedBox(width: DesignSpacing.md),
          Text('Editar Sensor', style: DesignTextStyles.cardTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nombre del sensor', style: TextStyle(color: DesignColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
          SizedBox(height: DesignSpacing.sm),
          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Ingrese el nombre',
              hintStyle: TextStyle(color: DesignColors.textSecondary),
              filled: true,
              fillColor: DesignColors.surface2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.md), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.md), borderSide: BorderSide(color: DesignColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.md), borderSide: BorderSide(color: DesignColors.cyan, width: 1.5)),
            ),
          ),
          SizedBox(height: DesignSpacing.lg),
          Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: DesignColors.border,
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Text(
              'Tipo: ${row.sensorType ?? '-'} · Unidad: ${row.unit ?? '-'}',
              style: DesignTextStyles.bodyText,
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
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.cyan,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
