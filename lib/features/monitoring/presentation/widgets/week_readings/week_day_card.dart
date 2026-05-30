import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/monitoring_view_models.dart';
import 'week_data.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


class WeekDayCard extends StatelessWidget {
  const WeekDayCard({
    super.key,
    required this.label,
    required this.day,
    required this.isToday,
    required this.readings,
    required this.unit,
  });

  final String label;
  final DateTime day;
  final bool isToday;
  final List<SensorReadingViewModel> readings;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final picked = pickDayReadings(readings);
    final countLabel = readings.isEmpty
        ? 'Sin lecturas'
        : 'Mostrando ${picked.length} de ${readings.length}';

    return Card(
      child: ExpansionTile(
        initiallyExpanded: isToday,
        tilePadding: EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Expanded(
              child: Text(label, style: DesignTextStyles.bodyText),
            ),
            if (isToday) ...[
              SizedBox(width: DesignSpacing.sm),
              Chip(
                label: Text('HOY', style: DesignTextStyles.timestamp.copyWith(color: DesignColors.green)),
                backgroundColor: Colors.green.withValues(alpha: 0.18),
                side: BorderSide(color: DesignTextStyles.timestamp.copyWith(color: DesignColors.green).color!),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${DateFormat('dd/MM').format(day)} · $countLabel',
          style: DesignTextStyles.bodyText,
        ),
        children: [
          if (readings.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No hay lecturas para este día.',
                style: DesignTextStyles.bodyText,
              ),
            )
          else if (picked.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No hay lecturas en el rango de tarde (12:00 - 22:59).',
                style: DesignTextStyles.bodyText,
              ),
            )
          else
            ...picked.map((r) {
              final value = unit.isEmpty ? r.value : '${r.value} $unit';
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.show_chart, color: DesignColors.textPrimary, size: 20),
                title: Text(value, style: DesignTextStyles.bodyText),
                subtitle: Text(fmtTime(r.timestamp), style: DesignTextStyles.bodyText),
              );
            }),
        ],
      ),
    );
  }
}
