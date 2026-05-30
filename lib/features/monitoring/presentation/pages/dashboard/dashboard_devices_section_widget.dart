import 'package:flutter/material.dart';
import '../../../data/models/monitoring_view_models.dart';
import '../../../data/models/reading/latest_reading_models.dart';
import '../../../data/models/device_with_sensor_view_model.dart';
import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Devices section widget for dashboard
class DashboardDevicesSectionWidget extends StatelessWidget {
  const DashboardDevicesSectionWidget({
    super.key,
    required this.snapshot,
    required this.formatDateTime,
  });

  final dynamic snapshot;
  final String Function(String?) formatDateTime;

  String _deviceTypeLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'refrigerator':
        return 'camara frigorifica';
      case 'environmental':
        return 'sensor ambiental';
      case 'energy_meter':
        return 'medidor electrico';
      default:
        return raw;
    }
  }

  String _sensorTypeLabel(String? raw) => date_utils.sensorTypeLabelShared(raw);

  Color _sensorAccentColor(String? raw) {
    final t = (raw ?? '').toLowerCase();
    switch (t) {
      case 'temperature':
        return DesignColors.amber;
      case 'humidity':
        return DesignColors.cyan;
      case 'air_quality':
        return Colors.tealAccent;
      case 'power':
        return Colors.purpleAccent;
      case 'voltage':
        return Colors.amberAccent;
      default:
        return DesignColors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (snapshot.loading && snapshot.data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.error != null && snapshot.data == null) {
      return Text('Error: ${snapshot.error}');
    }
    final sectionData = snapshot.data;
    if (sectionData == null || sectionData.devices.isEmpty) {
      return const Text('No hay dispositivos registrados.');
    }

    final rows = sectionData.devices;
    final latestReadings = sectionData.latestReadings;

    if (rows.isEmpty) {
      return const Text('No hay dispositivos registrados.');
    }

    final Map<String, LatestSensorReadingViewModel> latestBySensorId = {
      for (final r in latestReadings) r.sensorId: r,
    };

    final Map<String, List<DeviceWithSensorViewModel>> byDevice = {};
    for (final row in rows) {
      byDevice.putIfAbsent(row.deviceId, () => []).add(row);
    }
    final devices = byDevice.entries.toList()
      ..sort((a, b) => a.value.first.deviceName.compareTo(b.value.first.deviceName));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final entry = devices[index];
        final deviceRows = entry.value;
        final first = deviceRows.first;
        final isOnline = first.deviceStatus.toLowerCase() == 'online';

        return Card(
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              listTileTheme: ListTileThemeData(iconColor: DesignColors.textPrimary),
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg, vertical: DesignSpacing.sm),
              collapsedBackgroundColor: DesignColors.surface,
              backgroundColor: DesignColors.surface,
              leading: Icon(
                Icons.memory,
                color: isOnline
                    ? DesignColors.green
                    : DesignColors.red,
              ),
              title: Text(
                first.deviceName,
                style: DesignTextStyles.cardTitle,
              ),
              subtitle: Text(
                '${_deviceTypeLabel(first.deviceType)} · ${first.deviceStatus}',
                style: DesignTextStyles.bodyText,
              ),
              childrenPadding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg, vertical: DesignSpacing.sm),
              children: [
                if (first.lastConnection != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: DesignSpacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ultima conexion',
                          style: DesignTextStyles.timestamp,
                        ),
                        Text(
                          formatDateTime(first.lastConnection),
                          style: DesignTextStyles.bodyText,
                        ),
                      ],
                    ),
                  ),
                ...deviceRows.map((row) {
                  final rawSensorType = (row.sensorType ?? '-').trim();
                  final sensorTypeLabel = _sensorTypeLabel(rawSensorType);
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

                  final accent = _sensorAccentColor(rawSensorType);
                  final valueText = (latestValue ?? '-').toString();
                  final timeText = formatDateTime(latestTime);

                  return Container(
                    margin: EdgeInsets.only(bottom: DesignSpacing.sm),
                    padding: EdgeInsets.all(DesignSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(DesignRadius.md),
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
                            borderRadius: BorderRadius.circular(DesignRadius.md),
                            border: Border.all(color: accent.withValues(alpha: 0.35)),
                          ),
                          child: Icon(
                            _getSensorIcon(rawSensorType),
                            color: accent,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: DesignSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      sensorTypeLabel,
                                      style: DesignTextStyles.bodyText,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    valueText,
                                    style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: DesignSpacing.xs),
                              Text(
                                meta,
                                style: DesignTextStyles.bodyText,
                              ),
                              SizedBox(height: DesignSpacing.xs),
                              Text(
                                'Última lectura: $timeText',
                                style: DesignTextStyles.timestamp,
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
    );
  }

  IconData _getSensorIcon(String? raw) {
    final t = (raw ?? '').toLowerCase();
    switch (t) {
      case 'temperature':
        return Icons.thermostat_outlined;
      case 'humidity':
        return Icons.water_drop_outlined;
      case 'air_quality':
        return Icons.air_outlined;
      case 'power':
        return Icons.bolt_outlined;
      case 'voltage':
        return Icons.electrical_services_outlined;
      default:
        return Icons.sensors;
    }
  }
}
