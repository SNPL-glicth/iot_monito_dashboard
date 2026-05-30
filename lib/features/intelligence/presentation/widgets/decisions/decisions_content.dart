import 'package:flutter/material.dart';
import '../../../data/intelligence_models.dart';
import 'decision_card.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Contenido principal de la página de decisiones (carga, error, vacío, lista).
class DecisionsContent extends StatelessWidget {
  const DecisionsContent({
    super.key,
    required this.isLoading,
    required this.decisions,
    required this.error,
    required this.statusFilter,
    required this.severityFilter,
    required this.onRetry,
    required this.onUpdateStatus,
  });

  final bool isLoading;
  final List<DecisionActionViewModel>? decisions;
  final String? error;
  final String statusFilter;
  final String severityFilter;
  final VoidCallback onRetry;
  final void Function(DecisionActionViewModel decision, String status) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    if (isLoading && decisions == null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando decisiones...', style: DesignTextStyles.bodyText),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(DesignSpacing.lg),
                  decoration: BoxDecoration(
                    color: DesignColors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(Icons.error_outline_rounded, size: 48, color: DesignColors.red),
                ),
                SizedBox(height: DesignSpacing.lg),
                Text('Error al cargar decisiones', style: DesignTextStyles.cardTitle),
                SizedBox(height: DesignSpacing.sm),
                Text(
                  error!,
                  style: DesignTextStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: DesignSpacing.lg),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.cyan,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.md)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final items = decisions ?? [];

    if (items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(DesignSpacing.lg),
                  decoration: BoxDecoration(
                    color: DesignColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(Icons.check_circle_outline_rounded, size: 56, color: DesignColors.green),
                ),
                SizedBox(height: DesignSpacing.xl),
                Text('Sin decisiones pendientes', style: DesignTextStyles.screenTitle),
                SizedBox(height: DesignSpacing.md),
                Text(
                  statusFilter.isNotEmpty || severityFilter.isNotEmpty
                      ? 'No hay decisiones que coincidan con los filtros seleccionados.'
                      : 'El sistema no ha generado acciones recomendadas.\nEsto puede significar que no hay eventos anómalos recientes.',
                  style: DesignTextStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: DesignSpacing.xl),
                Container(
                  padding: EdgeInsets.all(DesignSpacing.lg),
                  decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded, color: DesignColors.cyan, size: 20),
                      SizedBox(width: DesignSpacing.md),
                      Flexible(
                        child: Text(
                          'Las decisiones se generan automáticamente\ncuando el ML detecta anomalías.',
                          style: DesignTextStyles.timestamp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => DecisionCard(
            decision: items[index],
            onUpdateStatus: (status) => onUpdateStatus(items[index], status),
          ),
          childCount: items.length,
        ),
      ),
    );
  }
}
