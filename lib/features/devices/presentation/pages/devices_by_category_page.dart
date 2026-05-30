import 'package:flutter/material.dart';
import '../../../../core/auth/user_role.dart';
import '../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../monitoring/data/models/monitoring_view_models.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../models/sensor_category.dart';
import 'sensor_detail_page.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


class DevicesByCategoryPage extends StatefulWidget {
  const DevicesByCategoryPage({
    super.key,
    required this.role,
    required this.category,
  });

  final UserRole role;
  final SensorCategory category;

  @override
  State<DevicesByCategoryPage> createState() => _DevicesByCategoryPageState();
}

class _DevicesByCategoryPageState extends State<DevicesByCategoryPage> {
  late final MonitoringRepository _repo;
  late Future<List<DeviceWithSensorViewModel>> _devicesFuture;
  late Future<List<LatestSensorReadingViewModel>> _latestFuture;

  @override
  void initState() {
    super.initState();
    _repo = MonitoringRepository();
    _devicesFuture = _repo.fetchDevicesWithSensors();
    _latestFuture = _repo.fetchLatestSensorReadings();
  }

  void _refresh() {
    setState(() {
      _devicesFuture = _repo.fetchDevicesWithSensors();
      _latestFuture = _repo.fetchLatestSensorReadings();
    });
  }

  SensorCategory _deviceCategory(String rawDeviceType) {
    final t = rawDeviceType.toLowerCase().trim();

    if (t == 'energy_meter' || t.contains('energy') || t.contains('electric')) {
      return SensorCategory.electricity;
    }

    if (t == 'refrigerator' || t.contains('frigo') || t.contains('refrig')) {
      return SensorCategory.temperature;
    }

    return SensorCategory.environmental;
  }

  SensorCategory sensorCategory({String? sensorType, String? unit}) {
    // Clasificación de SENSOR (para listar dentro de un device).
    final t = (sensorType ?? '').toLowerCase().trim();
    final u = (unit ?? '').toLowerCase().trim();

    if (t == 'temperature' || t.contains('temp')) return SensorCategory.temperature;
    if (u.contains('°c') || u == 'c') return SensorCategory.temperature;

    if (t == 'voltage' || t == 'power' || t.contains('electric') || t.contains('energy')) {
      return SensorCategory.electricity;
    }
    if (u == 'kw' || u == 'w' || u == 'v' || u.contains('volt')) return SensorCategory.electricity;

    if (t == 'humidity' || t == 'air_quality' || t.contains('air') || t.contains('humid')) {
      return SensorCategory.environmental;
    }
    if (u == '%' || u == 'ppm') return SensorCategory.environmental;

    return SensorCategory.environmental;
  }


  String _categoryTitle(SensorCategory c) {
    switch (c) {
      case SensorCategory.electricity:
        return 'Sensores de Electricidad';
      case SensorCategory.environmental:
        return 'Sensores Ambientales';
      case SensorCategory.temperature:
        return 'Sensores de Temperatura';
    }
  }

  IconData _categoryIcon(SensorCategory c) {
    switch (c) {
      case SensorCategory.electricity:
        return Icons.electrical_services_outlined;
      case SensorCategory.environmental:
        return Icons.eco_outlined;
      case SensorCategory.temperature:
        return Icons.thermostat_outlined;
    }
  }

  String _deviceTypeLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'refrigerator':
        return 'refrigeración';
      case 'environmental':
        return 'ambiental';
      case 'energy_meter':
        return 'eléctrico';
      default:
        return raw;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_categoryTitle(widget.category)),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _devicesFuture,
          _latestFuture,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data;
          if (data == null || data.length < 2) {
            return const Center(child: Text('Sin datos.'));
          }

          final rows = data[0] as List<DeviceWithSensorViewModel>;
          final latestReadings = data[1] as List<LatestSensorReadingViewModel>;

          final latestBySensorId = <String, LatestSensorReadingViewModel>{
            for (final r in latestReadings) r.sensorId: r,
          };

          // Regla: solo dispositivos de ESTA categoría (por deviceType).
          final inCategory = rows
              .where((r) => _deviceCategory(r.deviceType) == widget.category)
              .toList();

          // Dentro de esos dispositivos, mostramos TODOS los sensores del device.
          // (Ej: una nevera puede mostrar temperatura + humedad en la misma sección.)
          final sensors = inCategory
              .where((r) => r.sensorId != null)
              .toList();

          if (sensors.isEmpty) {
            return Center(
              child: Text(
                'No hay sensores para ${_categoryTitle(widget.category).toLowerCase()}.',
              ),
            );
          }

          // Agrupar por dispositivo para que el admin vea ordenado (y se vean
          // ambos sensores cuando un device tiene 2 del mismo grupo, ej: kW + V).
          final byDevice = <String, List<DeviceWithSensorViewModel>>{};
          for (final s in sensors) {
            byDevice.putIfAbsent(s.deviceId, () => []).add(s);
          }

          final devices = byDevice.entries.toList()
            ..sort((a, b) => a.value.first.deviceName.compareTo(b.value.first.deviceName));

          return ListView(
            padding: EdgeInsets.all(DesignSpacing.lg),
            children: [
              Card(
                child: ListTile(
                  leading: Icon(_categoryIcon(widget.category), color: Colors.tealAccent),
                  title: Text('Sensores disponibles', style: DesignTextStyles.cardTitle),
                  subtitle: Text(
                    'Dispositivos: ${devices.length} · Sensores: ${sensors.length}',
                    style: DesignTextStyles.bodyText,
                  ),
                ),
              ),
              SizedBox(height: DesignSpacing.sm),
              ...devices.map((entry) {
                final deviceRows = [...entry.value]
                  ..sort((a, b) => (a.sensorName ?? '').compareTo(b.sensorName ?? ''));
                final first = deviceRows.first;

                final isOnline = first.deviceStatus.toLowerCase() == 'online';

                return Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.memory,
                            color: isOnline
                                ? DesignColors.green
                                : DesignColors.red,
                          ),
                          title: Text(first.deviceName, style: DesignTextStyles.cardTitle),
                          subtitle: Text(
                            'Tipo: ${_deviceTypeLabel(first.deviceType)} · Estado: ${first.deviceStatus}',
                            style: DesignTextStyles.bodyText,
                          ),
                          trailing: Icon(Icons.chevron_right, color: DesignColors.textSecondary),
                          onTap: () {
                            // Por ahora mantenemos el comportamiento: al tocar el device,
                            // se navega al primer sensor. (Se reemplazará por Device Details)
                            final firstSensor = deviceRows.firstWhere(
                              (x) => (x.sensorId ?? '').isNotEmpty,
                              orElse: () => deviceRows.first,
                            );
                            final latest = firstSensor.sensorId == null
                                ? null
                                : latestBySensorId[firstSensor.sensorId!];
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SensorDetailPage(
                                  role: widget.role,
                                  row: firstSensor,
                                  latest: latest,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, color: Colors.white12),
                        ...deviceRows.map((row) {
                          final latest = row.sensorId == null ? null : latestBySensorId[row.sensorId!];
                          final unit = (row.unit ?? '').trim();
                          final latestValue = latest?.latestValue ?? '-';
                          final latestTime = latest?.latestTimestamp ?? '-';

                          return ListTile(
                            leading: Icon(Icons.sensors, color: DesignColors.cyan),
                            title: Text(row.sensorName ?? '(sin nombre)', style: DesignTextStyles.bodyText),
                            subtitle: Text(
                              'Tipo: ${row.sensorType ?? '-'} · Último: $latestValue${unit.isEmpty ? '' : ' $unit'} · $latestTime',
                              style: DesignTextStyles.bodyText,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SensorDetailPage(
                                    role: widget.role,
                                    row: row,
                                    latest: latest,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
