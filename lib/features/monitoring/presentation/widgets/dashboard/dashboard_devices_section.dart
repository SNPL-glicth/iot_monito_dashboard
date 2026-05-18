import 'package:flutter/material.dart';

import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../../../data/models/device_with_sensor_view_model.dart';
import '../../../data/models/reading/latest_reading_models.dart';
import '../../../data/models/sensor_consolidated_status_view_model.dart';
import '../../styles/dashboard_styles.dart';
import 'dashboard_helpers.dart';

/// Sección de dispositivos y sensores del dashboard.
class DashboardDevicesSection extends StatelessWidget {
  const DashboardDevicesSection({
    super.key,
    required this.devices,
    required this.latestReadings,
    this.statusBySensorId = const {},
  });

  final List<DeviceWithSensorViewModel> devices;
  final List<LatestSensorReadingViewModel> latestReadings;
  final Map<String, SensorConsolidatedStatusViewModel> statusBySensorId;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const Text('No hay dispositivos registrados.');
    }

    final latestBySensorId = <String, LatestSensorReadingViewModel>{
      for (final r in latestReadings) r.sensorId: r,
    };

    final byDevice = <String, List<DeviceWithSensorViewModel>>{};
    for (final row in devices) {
      byDevice.putIfAbsent(row.deviceId, () => []).add(row);
    }
    final sortedDevices = byDevice.entries.toList()
      ..sort((a, b) => a.value.first.deviceName.compareTo(b.value.first.deviceName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardHelpers.sectionHeader(
          icon: Icons.devices_other,
          title: 'Dispositivos y sensores',
          color: DashboardColors.sectionAccent,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedDevices.length,
          itemBuilder: (context, index) {
            final entry = sortedDevices[index];
            final deviceRows = entry.value;
            final first = deviceRows.first;
            final isOnline = first.deviceStatus.toLowerCase() == 'online';

            return Card(
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  listTileTheme: const ListTileThemeData(iconColor: Colors.white70),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  collapsedBackgroundColor: DashboardColors.cardBackground,
                  backgroundColor: DashboardColors.cardBackground,
                  leading: Icon(
                    Icons.memory,
                    color: isOnline
                        ? DashboardColors.deviceOnline
                        : DashboardColors.deviceOffline,
                  ),
                  title: Text(
                    first.deviceName,
                    style: DashboardTextStyles.deviceTitle,
                  ),
                  subtitle: Text(
                    '${DashboardHelpers.deviceTypeLabel(first.deviceType)}  ·  ${first.deviceStatus}',
                    style: DashboardTextStyles.deviceSubtitle,
                  ),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    if (first.lastConnection != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ultima conexion',
                              style: DashboardTextStyles.smallLabel,
                            ),
                            Text(
                              date_utils.formatDateTimeShared(first.lastConnection),
                              style: DashboardTextStyles.sensorMeta,
                            ),
                          ],
                        ),
                      ),
                    ...deviceRows.map((row) {
                      final isActive = row.sensorActive == true;
                      final rawSensorType = (row.sensorType ?? '-').trim();
                      final sensorTypeLabel = date_utils.sensorTypeLabelShared(rawSensorType);
                      final sensorName = (row.sensorName ?? '').trim();
                      final unit = (row.unit ?? '').trim();
                      final metaLeft = sensorName.isEmpty ? '—' : sensorName;
                      final meta = unit.isEmpty ? metaLeft : '$metaLeft · $unit';

                      LatestSensorReadingViewModel? latest;
                      if (row.sensorId != null) {
                        latest = latestBySensorId[row.sensorId!];
                      }
                      final latestValue = latest?.latestValue;
                      final latestTime = latest?.latestTimestamp;

                      final accent = DashboardHelpers.sensorAccentColor(rawSensorType);
                      final valueText = (latestValue ?? '-').toString();
                      final timeText = date_utils.formatDateTimeShared(latestTime);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: accent.withValues(alpha: 0.35)),
                              ),
                              child: Icon(
                                DashboardHelpers.sensorIcon(rawSensorType),
                                color: accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          sensorTypeLabel,
                                          style: DashboardTextStyles.sensorTitle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Chip(
                                        label: Text(
                                          isActive ? 'ACTIVO' : 'INACTIVO',
                                          style: isActive
                                              ? DashboardTextStyles.chipActive
                                              : DashboardTextStyles.chipInactive,
                                        ),
                                        backgroundColor: isActive
                                            ? Colors.green.withValues(alpha: 0.18)
                                            : Colors.red.withValues(alpha: 0.18),
                                        side: BorderSide(
                                          color: isActive
                                              ? DashboardTextStyles.chipActive.color!
                                              : DashboardTextStyles.chipInactive.color!,
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(meta, style: DashboardTextStyles.sensorMeta),
                                  if (latestValue != null || latestTime != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              valueText,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.2,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            timeText,
                                            style: DashboardTextStyles.smallLabel,
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
