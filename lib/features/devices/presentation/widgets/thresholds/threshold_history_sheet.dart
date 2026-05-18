import 'package:flutter/material.dart';

import '../../../../../features/monitoring/data/models/monitoring_view_models.dart';
import '../../../../../features/monitoring/data/monitoring_repository.dart';
import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Bottom sheet para mostrar el historial de cambios de un umbral.
Future<void> showThresholdHistorySheet({
  required BuildContext context,
  required MonitoringRepository repo,
  required AlertThresholdViewModel threshold,
}) async {
  List<ThresholdHistoryViewModel> history;

  try {
    history = await repo.fetchThresholdHistory(threshold.id);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar el historial: $e')),
      );
    }
    return;
  }

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) {
      return SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Historial: ${threshold.name}', style: DashboardTextStyles.sectionHeader),
            const SizedBox(height: 8),
            if (history.isEmpty)
              const Text('Sin cambios registrados.', style: DashboardTextStyles.sensorMeta)
            else
              ...history.map((h) {
                final from = '${h.oldMin ?? '-'} – ${h.oldMax ?? '-'}';
                final to = '${h.newMin ?? '-'} – ${h.newMax ?? '-'}';
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.white70),
                    title: Text(h.changedAt, style: DashboardTextStyles.sensorTitle),
                    subtitle: Text(
                      'De: $from\nA: $to\nPor: ${h.changedBy}${h.reason == null || h.reason!.trim().isEmpty ? '' : '\nRazón: ${h.reason}'}',
                      style: DashboardTextStyles.sensorMeta,
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    },
  );
}
