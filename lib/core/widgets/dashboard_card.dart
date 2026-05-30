import 'package:flutter/material.dart';
import '../../../core/theme/design_colors.dart';
import '../../../core/theme/design_spacing.dart';
import '../../../core/theme/design_text_styles.dart';


/// Card reutilizable para el dashboard con estilo moderno glassmorphism.
///
/// Características:
/// - Fondo oscuro con borde sutil
/// - Opcional: título con icono
/// - Contenido personalizable
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
    this.padding = const EdgeInsets.all(DesignSpacing.lg),
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: DesignColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.lg),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: DesignColors.cyan, size: 20),
                  SizedBox(width: DesignSpacing.sm),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: DesignTextStyles.cardTitle,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: DesignSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
