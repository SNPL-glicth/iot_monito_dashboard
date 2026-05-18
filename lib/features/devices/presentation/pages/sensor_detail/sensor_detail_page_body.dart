import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import 'point_details_dialog.dart';
import 'readings_expansion_tile.dart';
import 'sensor_detail_body.dart';

/// Body content for sensor detail page
class SensorDetailPageBody extends StatelessWidget {
  const SensorDetailPageBody({
    super.key,
    required this.dashboard,
    required this.realtimeData,
    required this.unit,
    required this.isSensorActive,
    required this.refreshing,
    required this.sensorType,
    required this.isFrozen,
    required this.deviceName,
    required this.onDay,
    required this.onWeek,
    required this.onMonth,
  });

  final dynamic dashboard;
  final dynamic realtimeData;
  final String unit;
  final bool isSensorActive;
  final bool refreshing;
  final String sensorType;
  final bool isFrozen;
  final String deviceName;
  final VoidCallback onDay;
  final VoidCallback onWeek;
  final VoidCallback onMonth;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(dashboard.row.sensorName ?? 'Sensor',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text('$deviceName · $sensorType', style: DashboardTextStyles.sensorMeta),
        const SizedBox(height: 12),
        SensorDetailBody(
          dashboard: dashboard,
          realtimeData: realtimeData,
          unit: unit,
          isSensorActive: isSensorActive,
          refreshing: refreshing,
          sensorType: sensorType,
          isFrozen: isFrozen,
          onPointTapped: (point) {
            showModalBottomSheet(
              context: context,
              builder: (_) => PointDetailsDialog(point: point, unit: unit),
            );
          },
        ),
        const SizedBox(height: 12),
        ReadingsExpansionTile(
          onDay: onDay,
          onWeek: onWeek,
          onMonth: onMonth,
        ),
        const SizedBox(height: 10),
        Text('Rol: ${dashboard.role.name}', style: DashboardTextStyles.smallLabel),
      ],
    );
  }
}
