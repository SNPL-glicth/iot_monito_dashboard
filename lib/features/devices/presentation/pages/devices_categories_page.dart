import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../monitoring/data/models/monitoring_view_models.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import 'device_detail_page.dart';

class DevicesCategoriesPage extends StatefulWidget {
  const DevicesCategoriesPage({
    super.key,
    required this.role,
  });

  final UserRole role;

  @override
  State<DevicesCategoriesPage> createState() => _DevicesCategoriesPageState();
}

class _DevicesCategoriesPageState extends State<DevicesCategoriesPage> {
  late final MonitoringRepository _repo;
  late Future<List<DeviceWithSensorViewModel>> _future;
  late Future<List<LatestSensorReadingViewModel>> _latestFuture;

  @override
  void initState() {
    super.initState();
    _repo = MonitoringRepository();
    _future = _repo.fetchDevicesWithSensors();
    _latestFuture = _repo.fetchLatestSensorReadings();
  }

  void refresh() {
    setState(() {
      _future = _repo.fetchDevicesWithSensors();
      _latestFuture = _repo.fetchLatestSensorReadings();
    });
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
        title: const Text('Dispositivos'),
        actions: [
          if (widget.role == UserRole.admin)
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed('/devices/create'),
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Agregar Dispositivo',
            ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_future, _latestFuture]),
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
          final latest = data[1] as List<LatestSensorReadingViewModel>;
          if (rows.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.devices_other_rounded, size: 64, color: DashboardColors.white54),
                  const SizedBox(height: 16),
                  Text('No hay dispositivos registrados', style: DashboardTextStyles.deviceTitle),
                  const SizedBox(height: 8),
                  Text('Agrega tu primer dispositivo para comenzar', style: DashboardTextStyles.sensorMeta),
                ],
              ),
            );
          }

          // Agrupar por deviceId: 1 tarjeta por dispositivo
          final byDevice = <String, List<DeviceWithSensorViewModel>>{};
          for (final r in rows) {
            byDevice.putIfAbsent(r.deviceId, () => []).add(r);
          }

          final devices = byDevice.entries.toList()
            ..sort((a, b) => a.value.first.deviceName.compareTo(b.value.first.deviceName));

          final latestBySensorId = <String, LatestSensorReadingViewModel>{
            for (final r in latest) r.sensorId: r,
          };

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header con contador
              Container(
                padding: const EdgeInsets.all(16),
                decoration: ModernCardDecoration.gradient(DashboardColors.gradientPrimary),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.devices_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mis Dispositivos', style: DashboardTextStyles.deviceTitle),
                        const SizedBox(height: 2),
                        Text(
                          '${devices.length} dispositivo${devices.length != 1 ? 's' : ''} registrado${devices.length != 1 ? 's' : ''}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Lista de dispositivos
              ...devices.map((entry) {
                final deviceRows = entry.value;
                final first = deviceRows.first;

                final sensorRows = deviceRows.where((r) => (r.sensorId ?? '').isNotEmpty).toList();
                final sensorCount = sensorRows.length;
                final isOnline = first.deviceStatus.toLowerCase() == 'online';

                // Última lectura global
                LatestSensorReadingViewModel? latestDevice;
                DateTime? best;
                for (final s in sensorRows) {
                  final lr = latestBySensorId[s.sensorId!];
                  if (lr == null) continue;
                  final dt = DateTime.tryParse(lr.latestTimestamp ?? '');
                  if (dt == null) continue;
                  if (best == null || dt.isAfter(best)) {
                    best = dt;
                    latestDevice = lr;
                  }
                }

                final lastValue = latestDevice?.latestValue ?? '-';
                final lastTs = latestDevice?.latestTimestamp ?? '-';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: ModernCardDecoration.elevated(),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DeviceDetailPage(
                                role: widget.role,
                                deviceId: first.deviceId,
                                deviceName: first.deviceName,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (isOnline ? DashboardColors.success : DashboardColors.error).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.memory_rounded,
                                  color: isOnline ? DashboardColors.success : DashboardColors.error,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            first.deviceName,
                                            style: DashboardTextStyles.deviceTitle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (isOnline ? DashboardColors.success : DashboardColors.error).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isOnline ? 'Online' : 'Offline',
                                            style: TextStyle(
                                              color: isOnline ? DashboardColors.success : DashboardColors.error,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_deviceTypeLabel(first.deviceType)} · $sensorCount sensores',
                                      style: DashboardTextStyles.sensorMeta,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Último: $lastValue · $lastTs',
                                      style: DashboardTextStyles.smallLabel,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: DashboardColors.white54),
                            ],
                          ),
                        ),
                      ),
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
