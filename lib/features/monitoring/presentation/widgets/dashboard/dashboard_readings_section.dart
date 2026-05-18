import 'package:flutter/material.dart';

import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../../../data/models/reading/latest_reading_models.dart';
import '../../styles/dashboard_styles.dart';
import 'dashboard_helpers.dart';

/// Sección de últimas lecturas por sensor del dashboard.
class DashboardReadingsSection extends StatelessWidget {
  const DashboardReadingsSection({
    super.key,
    required this.readings,
  });

  final List<LatestSensorReadingViewModel> readings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardHelpers.sectionHeader(
          icon: Icons.show_chart,
          title: 'Ultimas lecturas por sensor',
          color: DashboardColors.sensorIcon,
        ),
        const SizedBox(height: 8),
        if (readings.isEmpty)
          const Text('No hay lecturas registradas.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: readings.length,
            itemBuilder: (context, index) {
              final row = readings[index];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(
                      Icons.sensors,
                      color: DashboardColors.sensorIcon,
                    ),
                    title: Text(
                      '${row.sensorName} (${row.unit})',
                      style: DashboardTextStyles.sensorTitle,
                    ),
                    subtitle: Text(
                      'dispositivo: ${row.deviceName}\n'
                      'ultimo valor: ${row.latestValue ?? '-'}\n'
                      'fecha: ${date_utils.formatDateTimeShared(row.latestTimestamp)}',
                      style: DashboardTextStyles.sensorMeta,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
