import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/user_role.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../../monitoring/presentation/pages/sensor_readings_page.dart';
import '../../data/crm_repository.dart';
import '../../data/models/crm_devices_models.dart';

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
        return Colors.orangeAccent;
      case 'humidity':
        return Colors.lightBlueAccent;
      case 'air_quality':
        return Colors.tealAccent;
      case 'power':
        return Colors.purpleAccent;
      case 'voltage':
        return Colors.amberAccent;
      default:
        return DashboardColors.sensorIcon;
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
          padding: const EdgeInsets.all(16),
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
                return Center(child: Text('Error: ${snapshot.error}', style: DashboardTextStyles.error));
              }

              final data = snapshot.data;
              if (data == null) {
                return const Center(child: Text('Sin datos.', style: DashboardTextStyles.sensorMeta));
              }

              final latestBySensorId = <String, CrmLatestReading>{
                for (final r in data.latestReadings) r.sensorId: r,
              };

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rango: ${_formatDateTime(data.from)} → ${_formatDateTime(data.to)} (bucket: ${data.bucket})',
                    style: DashboardTextStyles.sensorMeta,
                  ),
                  const SizedBox(height: 12),

                  Text('Sensores (series agregadas)', style: DashboardTextStyles.sectionHeader),
                  const SizedBox(height: 8),

                  if (data.sensors.isEmpty)
                    const Text('No hay sensores.', style: DashboardTextStyles.sensorMeta)
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
                          padding: const EdgeInsets.all(12),
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
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: accent.withValues(alpha: 0.35)),
                                    ),
                                    child: Icon(
                                      _sensorIcon(sensor.sensorType),
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
                                                sensor.name,
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
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tipo: ${sensor.sensorType} · Unidad: ${sensor.unit}',
                                          style: DashboardTextStyles.sensorMeta,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
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
                                  const SizedBox(width: 8),
                                  Text(tsText, style: DashboardTextStyles.smallLabel),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Serie: ${points.length} puntos · avg(min/max): '
                                '${lastPoint == null ? '-' : '${lastPoint.avg} (${lastPoint.min}/${lastPoint.max})'}',
                                style: DashboardTextStyles.sensorMeta,
                              ),
                              const SizedBox(height: 10),
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
