import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar un estado/etiqueta con color.
///
/// Características:
/// - Etiqueta de texto con fondo de color
/// - Borde sutil
/// - Compacto (visualDensity.compact)
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? color.withValues(alpha: 0.18);

    return Chip(
      label: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: effectiveBgColor,
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
