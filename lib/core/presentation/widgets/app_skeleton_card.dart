import 'package:flutter/material.dart';

import '../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Widget skeleton estandarizado para tarjetas de carga.
///
/// Muestra un bloque con el color de superficie elevada del dashboard,
/// útil para estados de carga de listas y grids. Reemplaza los
/// `_SkeletonCard` y `_SkeletonLine` dispersos por módulo.
class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({
    super.key,
    this.height = 80,
    this.width,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.child,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsets padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DashboardColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: padding,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

/// Línea de skeleton estandarizada para textos placeholder.
class AppSkeletonLine extends StatelessWidget {
  const AppSkeletonLine({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 6,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DashboardColors.surfaceElevated,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
