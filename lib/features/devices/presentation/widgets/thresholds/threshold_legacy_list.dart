import 'package:flutter/material.dart';
import '../../../../../features/monitoring/data/models/monitoring_view_models.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Lista expandible de umbrales legacy.
class ThresholdLegacyList extends StatelessWidget {
  const ThresholdLegacyList({
    super.key,
    required this.thresholds,
    required this.canEdit,
    required this.onEdit,
    required this.onHistory,
    required this.formatRule,
  });

  final List<AlertThresholdViewModel> thresholds;
  final bool canEdit;
  final void Function(AlertThresholdViewModel) onEdit;
  final void Function(AlertThresholdViewModel) onHistory;
  final String Function(AlertThresholdViewModel) formatRule;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.symmetric(horizontal: 12),
      title: Text('Umbrales legacy (alert_thresholds)', style: DesignTextStyles.cardTitle),
      children: [
        Padding(
          padding: EdgeInsets.all(DesignSpacing.md),
          child: Column(
            children: [
              if (thresholds.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sin límites legacy configurados.',
                    style: DesignTextStyles.bodyText,
                  ),
                )
              else ...[
                if (thresholds.length > 1)
                  Padding(
                    padding: EdgeInsets.only(bottom: DesignSpacing.sm),
                    child: Text(
                      'Aviso: hay más de un límite legacy activo para este sensor (dato legado).',
                      style: DesignTextStyles.bodyText,
                    ),
                  ),
                ...thresholds.map((t) {
                  final rule = formatRule(t);
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.rule, color: DesignColors.textPrimary),
                      title: Text(t.name, style: DesignTextStyles.bodyText),
                      subtitle: Text(
                        'Severidad: ${t.severity}\n$rule',
                        style: DesignTextStyles.bodyText,
                      ),
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          IconButton(
                            onPressed: () => onHistory(t),
                            icon: const Icon(Icons.history),
                            tooltip: 'Ver historial',
                          ),
                          if (canEdit)
                            IconButton(
                              onPressed: () => onEdit(t),
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Editar legacy',
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
