import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Estado vacío para la página de advertencias inteligentes.
class WarningEmptyState extends StatelessWidget {
  const WarningEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.tealAccent.withValues(alpha: 0.4),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Sin advertencias activas',
              style: DesignTextStyles.cardTitle,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'El sistema de inteligencia artificial no ha detectado\nanomalías o predicciones de riesgo.',
              style: DesignTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
