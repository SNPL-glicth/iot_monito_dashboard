import 'package:flutter/material.dart';
import '../../../../../features/monitoring/data/models/monitoring_view_models.dart';
import '../../../../../features/monitoring/data/monitoring_repository.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


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
          padding: EdgeInsets.all(DesignSpacing.lg),
          children: [
            Text('Historial: ${threshold.name}', style: DesignTextStyles.screenTitle),
            SizedBox(height: DesignSpacing.sm),
            if (history.isEmpty)
              Text('Sin cambios registrados.', style: DesignTextStyles.bodyText)
            else
              ...history.map((h) {
                final from = '${h.oldMin ?? '-'} – ${h.oldMax ?? '-'}';
                final to = '${h.newMin ?? '-'} – ${h.newMax ?? '-'}';
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.history, color: DesignColors.textPrimary),
                    title: Text(h.changedAt, style: DesignTextStyles.bodyText),
                    subtitle: Text(
                      'De: $from\nA: $to\nPor: ${h.changedBy}${h.reason == null || h.reason!.trim().isEmpty ? '' : '\nRazón: ${h.reason}'}',
                      style: DesignTextStyles.bodyText,
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
