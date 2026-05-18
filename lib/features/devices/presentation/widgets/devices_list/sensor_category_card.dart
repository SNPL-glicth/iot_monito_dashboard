import 'package:flutter/material.dart';

import '../../../../../core/auth/user_role.dart';
import '../../../../../features/monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../../../features/monitoring/data/models/monitoring_view_models.dart';
import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';
import '../../pages/sensor_detail_page.dart';
import 'device_filter_helpers.dart';

/// Tarjeta representativa de una categoría de sensores.
class SensorCategoryCard extends StatelessWidget {
  const SensorCategoryCard({
    super.key,
    required this.category,
    required this.representative,
    required this.sensorsInCategory,
    required this.latest,
    required this.role,
    required this.onDeleted,
  });

  final SensorCategory category;
  final DeviceWithSensorViewModel representative;
  final int sensorsInCategory;
  final LatestSensorReadingViewModel? latest;
  final UserRole role;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final isOnline = representative.deviceStatus.toLowerCase() == 'online';
    final unit = (representative.unit ?? '').trim();
    final latestValue = latest?.latestValue;
    final latestTime = latest?.latestTimestamp;

    final subtitleLines = <String>[
      'Dispositivo: ${representative.deviceName} (${deviceTypeLabel(representative.deviceType)})',
      'Estado: ${representative.deviceStatus}',
      'Último valor: ${latestValue ?? '-'}${unit.isEmpty ? '' : ' $unit'}',
      'Fecha: ${formatDateTime(latestTime)}',
      if (sensorsInCategory > 1) 'Nota: hay $sensorsInCategory sensores en esta categoría; se muestra 1.',
    ];

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.sensors,
          color: isOnline
              ? DashboardColors.deviceOnline
              : DashboardColors.deviceOffline,
        ),
        title: Text(
          category.title,
          style: DashboardTextStyles.deviceTitle,
        ),
        subtitle: Text(
          subtitleLines.join('\n'),
          style: DashboardTextStyles.sensorMeta,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await Navigator.of(context).push<String>(
            MaterialPageRoute(
              builder: (_) => SensorDetailPage(
                role: role,
                row: representative,
                latest: latest,
              ),
            ),
          );
          if (result == 'deleted' && context.mounted) {
            onDeleted();
          }
        },
      ),
    );
  }
}
