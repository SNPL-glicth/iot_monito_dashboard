import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/user_role.dart';
import '../../../monitoring/presentation/pages/sensor_readings_page.dart';
import '../../data/crm_repository.dart';
import '../../data/models/crm_devices_models.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


class CrmDeviceHistoryPage extends StatefulWidget {
  const CrmDeviceHistoryPage({
    super.key,
    required this.role,
    required this.deviceId,
    this.deviceNameHint,
  });

  final UserRole role;
  final int deviceId;
  final String? deviceNameHint;

  @override
  State<CrmDeviceHistoryPage> createState() => _CrmDeviceHistoryPageState();
}

class _CrmDeviceHistoryPageState extends State<CrmDeviceHistoryPage> {
  late final CrmRepository _repo;
  late Future<CrmDeviceProfileFullResponse> _future;

  @override
  void initState() {
    super.initState();
    _repo = CrmRepository();
    _future = _repo.getDeviceProfileFull(deviceId: widget.deviceId, maxSensors: 20, maxPoints: 600, alertsLimit: 200);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _repo.getDeviceProfileFull(deviceId: widget.deviceId, maxSensors: 20, maxPoints: 600, alertsLimit: 200);
    });
    await _future;
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final iso = DateTime.tryParse(raw);
    if (iso != null) {
      return DateFormat('dd/MM/yyyy HH:mm').format(iso.toLocal());
    }
    return raw;
  }

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

  IconData _sensorIcon(String? raw) {
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

  @override
  Widget build(BuildContext context) {
    final title = widget.deviceNameHint ?? 'Histórico y métricas';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: FutureBuilder<CrmDeviceProfileFullResponse>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: DesignTextStyles.bodyText));
              }

              final data = snapshot.data;
              if (data == null) {
                return Center(child: Text('Sin datos.', style: DesignTextStyles.bodyText));
              }

              final latestBySensorId = <String, CrmLatestReading>{
                for (final r in data.latestReadings) r.sensorId: r,
              };

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rango: ${_formatDateTime(data.from)} → ${_formatDateTime(data.to)} (bucket: ${data.bucket})',
                    style: DesignTextStyles.bodyText,
                  ),
                  SizedBox(height: DesignSpacing.md),

                  Text('Sensores (series agregadas)', style: DesignTextStyles.screenTitle),
                  SizedBox(height: DesignSpacing.sm),

                  if (data.sensors.isEmpty)
                    Text('No hay sensores.', style: DesignTextStyles.bodyText)
                  else
                    ...data.sensors.map((sensor) {
                      final latest = latestBySensorId[sensor.id];
                      final lastValue = latest?.latestValue;
                      final lastTs = latest?.latestTimestamp;
                      final points = sensor.points;
                      final lastPoint = points.isNotEmpty ? points.last : null;

                      final isActive = (sensor.isActive ?? true);
                      final accent = _sensorAccentColor(sensor.sensorType);

                      final valueText = (lastValue ?? '-').toString();
                      final tsText = _formatDateTime(lastTs);

                      return Card(
                        child: Padding(
                          padding: EdgeInsets.all(DesignSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                                      _sensorIcon(sensor.sensorType),
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
                                          children: [
                                            Expanded(
                                              child: Text(
                                                sensor.name,
                                                style: DesignTextStyles.bodyText,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: DesignSpacing.sm),
                                            Chip(
                                              label: Text(
                                                isActive ? 'ACTIVO' : 'INACTIVO',
                                                style: isActive
                                                    ? DesignTextStyles.timestamp.copyWith(color: DesignColors.green)
                                                    : DesignTextStyles.timestamp.copyWith(color: DesignColors.red),
                                              ),
                                              backgroundColor: isActive
                                                  ? Colors.green.withValues(alpha: 0.18)
                                                  : Colors.red.withValues(alpha: 0.18),
                                              side: BorderSide(
                                                color: isActive
                                                    ? DesignTextStyles.timestamp.copyWith(color: DesignColors.green).color!
                                                    : DesignTextStyles.timestamp.copyWith(color: DesignColors.red).color!,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: DesignSpacing.xs),
                                        Text(
                                          'Tipo: ${sensor.sensorType} · Unidad: ${sensor.unit}',
                                          style: DesignTextStyles.bodyText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: DesignSpacing.sm),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      valueText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: DesignSpacing.sm),
                                  Text(tsText, style: DesignTextStyles.timestamp),
                                ],
                              ),
                              SizedBox(height: DesignSpacing.sm),
                              Text(
                                'Serie: ${points.length} puntos · avg(min/max): '
                                '${lastPoint == null ? '-' : '${lastPoint.avg} (${lastPoint.min}/${lastPoint.max})'}',
                                style: DesignTextStyles.bodyText,
                              ),
                              SizedBox(height: DesignSpacing.sm),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => SensorReadingsPage(
                                          role: widget.role,
                                          sensorId: sensor.id,
                                          sensorNameHint: sensor.name,
                                          unitHint: sensor.unit,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.list_alt, size: 18),
                                  label: const Text('Ver lecturas'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
