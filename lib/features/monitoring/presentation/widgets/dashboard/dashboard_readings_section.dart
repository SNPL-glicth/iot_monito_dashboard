import 'package:flutter/material.dart';
import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../../../data/models/reading/latest_reading_models.dart';
import 'dashboard_helpers.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';
import '../../../../../core/theme/design_colors.dart';


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
          color: DesignColors.cyan,
        ),
        SizedBox(height: DesignSpacing.sm),
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
                  padding: EdgeInsets.symmetric(vertical: DesignSpacing.xs),
                  child: ListTile(
                    leading: Icon(
                      Icons.sensors,
                      color: DesignColors.cyan,
                    ),
                    title: Text(
                      '${row.sensorName} (${row.unit})',
                      style: DesignTextStyles.bodyText,
                    ),
                    subtitle: Text(
                      'dispositivo: ${row.deviceName}\n'
                      'ultimo valor: ${row.latestValue ?? '-'}\n'
                      'fecha: ${date_utils.formatDateTimeShared(row.latestTimestamp)}',
                      style: DesignTextStyles.bodyText,
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
