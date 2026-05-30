import 'package:flutter/material.dart';
import '../../data/models/admin_user.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Muestra diálogo de confirmación para eliminar un usuario.
Future<bool> showDeleteUserDialog({
  required BuildContext context,
  required AdminUser user,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
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
            Text('Eliminar usuario', style: DesignTextStyles.cardTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Seguro que deseas eliminar a ${user.username}?',
              style: const TextStyle(color: Colors.white, fontSize: 15),
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
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: DesignColors.textPrimary),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );

  return ok == true;
}
