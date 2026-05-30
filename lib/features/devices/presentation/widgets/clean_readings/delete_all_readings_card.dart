import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Card para eliminar todas las lecturas de sensores.
class DeleteAllReadingsCard extends StatelessWidget {
  const DeleteAllReadingsCard({
    super.key,
    required this.isBusy,
    required this.onConfirm,
  });

  final bool isBusy;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignColors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Icon(Icons.delete_forever_rounded, color: DesignColors.red, size: 22),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Eliminar TODAS las lecturas', style: DesignTextStyles.cardTitle),
                    SizedBox(height: 2),
                    Text('Borra todas las filas de lecturas. Ideal para reiniciar entorno demo.', style: DesignTextStyles.bodyText),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.md)),
              ),
              onPressed: isBusy ? null : onConfirm,
              child: isBusy
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Eliminar todas las lecturas'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
