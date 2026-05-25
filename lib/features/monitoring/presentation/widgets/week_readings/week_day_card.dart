import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/monitoring_view_models.dart';
import '../../styles/dashboard_styles.dart';
import 'week_data.dart';

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
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Expanded(
              child: Text(label, style: DashboardTextStyles.sensorTitle),
            ),
            if (isToday) ...[
              const SizedBox(width: 8),
              Chip(
                label: Text('HOY', style: DashboardTextStyles.chipActive),
                backgroundColor: Colors.green.withValues(alpha: 0.18),
                side: BorderSide(color: DashboardTextStyles.chipActive.color!),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${DateFormat('dd/MM').format(day)} · $countLabel',
          style: DashboardTextStyles.sensorMeta,
        ),
        children: [
          if (readings.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No hay lecturas para este día.',
                style: DashboardTextStyles.sensorMeta,
              ),
            )
          else if (picked.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No hay lecturas en el rango de tarde (12:00 - 22:59).',
                style: DashboardTextStyles.sensorMeta,
              ),
            )
          else
            ...picked.map((r) {
              final value = unit.isEmpty ? r.value : '${r.value} $unit';
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.show_chart, color: Colors.white70, size: 20),
                title: Text(value, style: DashboardTextStyles.sensorTitle),
                subtitle: Text(fmtTime(r.timestamp), style: DashboardTextStyles.sensorMeta),
              );
            }),
        ],
      ),
    );
  }
}
