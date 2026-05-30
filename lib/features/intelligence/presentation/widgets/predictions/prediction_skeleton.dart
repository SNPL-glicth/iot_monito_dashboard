import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


/// Skeleton que replica el layout de PredictionCard con placeholders.
class PredictionSkeletonCard extends StatelessWidget {
  const PredictionSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: icono + título + score circular
            Row(
              children: [
                _placeholderBox(width: 24, height: 24, radius: 4),
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: _placeholderBox(width: 140, height: 14, radius: 4),
                ),
                _placeholderBox(width: 48, height: 48, radius: 24),
              ],
            ),
            SizedBox(height: DesignSpacing.xs),
            _placeholderBox(width: 100, height: 10, radius: 4),
            SizedBox(height: DesignSpacing.sm),
            // Valor esperado + Horizonte
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _placeholderBox(width: 80, height: 10, radius: 4),
                    SizedBox(height: DesignSpacing.xs),
                    _placeholderBox(width: 60, height: 18, radius: 4),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _placeholderBox(width: 50, height: 10, radius: 4),
                    SizedBox(height: DesignSpacing.xs),
                    _placeholderBox(width: 70, height: 12, radius: 4),
                    SizedBox(height: DesignSpacing.xs),
                    _placeholderBox(width: 80, height: 10, radius: 4),
                  ],
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.sm),
            // Tendencia
            Row(
              children: [
                _placeholderBox(width: 20, height: 20, radius: 4),
                SizedBox(width: 6),
                _placeholderBox(width: 120, height: 12, radius: 4),
              ],
            ),
            SizedBox(height: DesignSpacing.sm),
            // Severidad chip + Anomalía barra
            Row(
              children: [
                _placeholderBox(width: 80, height: 24, radius: 12),
                SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _placeholderBox(width: 50, height: 10, radius: 4),
                          _placeholderBox(width: 30, height: 10, radius: 4),
                        ],
                      ),
                      SizedBox(height: 6),
                      _placeholderBox(height: 6, radius: 3),
                      SizedBox(height: DesignSpacing.xs),
                      _placeholderBox(width: 80, height: 10, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.sm),
            _placeholderBox(width: double.infinity, height: 12, radius: 4),
            SizedBox(height: DesignSpacing.xs),
            _placeholderBox(width: 180, height: 10, radius: 4),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox({double? width, required double height, required double radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DesignColors.surface2,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Lista de skeletons para el estado de carga de predicciones.
class PredictionsSkeletonList extends StatelessWidget {
  const PredictionsSkeletonList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(DesignSpacing.lg),
      itemCount: itemCount,
      itemBuilder: (context, index) => const PredictionSkeletonCard(),
    );
  }
}
