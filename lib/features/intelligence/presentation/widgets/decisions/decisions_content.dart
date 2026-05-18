import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';
import '../../../data/intelligence_models.dart';
import 'decision_card.dart';

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
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando decisiones...', style: DashboardTextStyles.sensorMeta),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DashboardColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.error_outline_rounded, size: 48, color: DashboardColors.error),
                ),
                const SizedBox(height: 20),
                const Text('Error al cargar decisiones', style: DashboardTextStyles.deviceTitle),
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: DashboardTextStyles.sensorMeta,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: DashboardColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded, size: 56, color: DashboardColors.success),
                ),
                const SizedBox(height: 24),
                const Text('Sin decisiones pendientes', style: DashboardTextStyles.sectionHeader),
                const SizedBox(height: 12),
                Text(
                  statusFilter.isNotEmpty || severityFilter.isNotEmpty
                      ? 'No hay decisiones que coincidan con los filtros seleccionados.'
                      : 'El sistema no ha generado acciones recomendadas.\nEsto puede significar que no hay eventos anómalos recientes.',
                  style: DashboardTextStyles.sensorMeta,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: ModernCardDecoration.elevated(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: DashboardColors.info, size: 20),
                      const SizedBox(width: 12),
                      const Flexible(
                        child: Text(
                          'Las decisiones se generan automáticamente\ncuando el ML detecta anomalías.',
                          style: DashboardTextStyles.smallLabel,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
