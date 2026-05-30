import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Diálogo de confirmación para eliminar todas las lecturas.
Future<bool> showConfirmDeleteAllDialog(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
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
            child: Icon(Icons.delete_forever_rounded, color: DesignColors.red, size: 20),
          ),
          SizedBox(width: DesignSpacing.md),
          Text('Confirmar eliminación', style: DesignTextStyles.cardTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Esto eliminará TODAS las lecturas de sensores del sistema.',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          SizedBox(height: DesignSpacing.md),
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
                    'Esta acción no se puede deshacer.',
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
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(foregroundColor: DesignColors.textPrimary),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
          ),
          child: const Text('Eliminar todo'),
        ),
      ],
    ),
  );
  return confirm == true;
}

/// Diálogo de confirmación para eliminar lecturas de un sensor específico.
Future<bool> showConfirmDeleteBySensorDialog(
  BuildContext context, {
  required String sensorLabel,
}) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
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
            child: Icon(Icons.delete_outline_rounded, color: DesignColors.amber, size: 20),
          ),
          SizedBox(width: DesignSpacing.md),
          Text('Confirmar eliminación', style: DesignTextStyles.cardTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Se eliminarán permanentemente todas las lecturas del sensor:',
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          SizedBox(height: DesignSpacing.md),
          Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: DesignColors.surface2,
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              border: Border.all(color: DesignColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.sensors_rounded, color: DesignColors.cyan, size: 18),
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text(
                    sensorLabel,
                    style: TextStyle(color: DesignColors.cyan, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: DesignSpacing.md),
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
                    'Esta acción no se puede deshacer.',
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
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(foregroundColor: DesignColors.textPrimary),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
          ),
          child: const Text('Eliminar lecturas'),
        ),
      ],
    ),
  );
  return confirm == true;
}
