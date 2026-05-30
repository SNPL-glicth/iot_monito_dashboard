import 'package:flutter/material.dart';
import '../../../../../features/monitoring/data/models/monitoring_view_models.dart';
import '../../../../../features/monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../../../features/monitoring/data/models/sensor_consolidated_status_view_model.dart';
import '../device_detail_helpers.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Tile de un sensor en la lista del dispositivo.
class SensorListTile extends StatelessWidget {
  const SensorListTile({
    super.key,
    required this.row,
    required this.status,
    required this.latest,
    required this.onTap,
  });

  final DeviceWithSensorViewModel row;
  final SensorConsolidatedStatusViewModel? status;
  final LatestSensorReadingViewModel? latest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sid = row.sensorId!;
    final state = status?.finalState ?? 'unknown';
    final unit = (row.unit ?? '').trim();
    final lastVal = latest?.latestValue ?? '-';
    final lastTs = DeviceDetailHelpers.formatDateTime(latest?.latestTimestamp);

    final deviceStatus = row.deviceStatus.toLowerCase();
    final isActive = row.sensorActive == true;
    final isPending = deviceStatus == 'draft' ||
        deviceStatus == 'pending_claim' ||
        deviceStatus == 'pending_confirmation' ||
        deviceStatus == 'pending_activation';

    final (Color sensorColor, IconData sensorIcon, String statusLabel) =
        DeviceDetailHelpers.getSensorDisplayInfo(state, isPending, isActive, deviceStatus);

    return Card(
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sensorIcon, color: sensorColor),
            if (isPending || !isActive)
              Container(
                margin: EdgeInsets.only(top: DesignSpacing.xs),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: sensorColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPending ? 'PEND' : 'OFF',
                  style: TextStyle(color: sensorColor, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        title: Text(
          (row.sensorName ?? '').trim().isEmpty ? 'Sensor $sid' : row.sensorName!.trim(),
          style: DesignTextStyles.bodyText,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$statusLabel · Último: $lastVal${unit.isEmpty ? '' : ' $unit'} · $lastTs',
              style: DesignTextStyles.bodyText,
            ),
            if (isPending)
              Padding(
                padding: EdgeInsets.only(top: DesignSpacing.xs),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
                  decoration: BoxDecoration(
                    color: DesignColors.textSecondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: DesignColors.textSecondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 12, color: DesignColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        DeviceDetailHelpers.getPendingActionHint(deviceStatus),
                        style: TextStyle(color: DesignColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: DesignColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
