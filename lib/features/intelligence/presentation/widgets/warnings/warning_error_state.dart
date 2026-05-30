import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Estado de error para la página de advertencias inteligentes.
class WarningErrorState extends StatelessWidget {
  const WarningErrorState({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: DesignColors.red.withValues(alpha: 0.6),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              'Error cargando advertencias',
              style: DesignTextStyles.cardTitle,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              error,
              style: DesignTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
