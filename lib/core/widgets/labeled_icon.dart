import 'package:flutter/material.dart';
import '../../../core/theme/design_colors.dart';
import '../../../core/theme/design_spacing.dart';


/// Widget reutilizable para mostrar un icono con etiqueta al lado.
///
/// Características:
/// - Icono con color personalizable
/// - Etiqueta de texto
/// - Espaciado consistente (8px)
class LabeledIcon extends StatelessWidget {
  const LabeledIcon({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.iconSize = 20,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? DesignColors.textPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: effectiveColor, size: iconSize),
        SizedBox(width: DesignSpacing.sm),
        Text(
          label,
          style: TextStyle(
            color: effectiveColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
