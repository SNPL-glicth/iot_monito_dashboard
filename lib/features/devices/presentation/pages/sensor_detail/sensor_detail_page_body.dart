import 'package:flutter/material.dart';

import '../../../../../core/auth/user_role.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';
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
    required this.sensorName,
    required this.role,
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
  final String sensorName;
  final UserRole role;
  final VoidCallback onDay;
  final VoidCallback onWeek;
  final VoidCallback onMonth;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(DesignSpacing.lg),
      children: [
        Text(sensorName, style: DesignTextStyles.cardTitle.copyWith(fontSize: 20)),
        SizedBox(height: DesignSpacing.xs),
        Text('$deviceName · $sensorType', style: DesignTextStyles.bodyText),
        SizedBox(height: DesignSpacing.md),
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
        SizedBox(height: DesignSpacing.md),
        ReadingsExpansionTile(
          onDay: onDay,
          onWeek: onWeek,
          onMonth: onMonth,
        ),
        SizedBox(height: DesignSpacing.sm),
        Text('Rol: ${role.name}', style: DesignTextStyles.timestamp),
      ],
    );
  }
}
