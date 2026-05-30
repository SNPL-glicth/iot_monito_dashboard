import 'package:flutter/material.dart';
import '../../../../core/auth/user_role.dart';
import '../../../monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../monitoring/data/models/monitoring_view_models.dart';
import '../../../monitoring/data/models/sensor_consolidated_status_view_model.dart';
import '../../../monitoring/data/monitoring_repository.dart';
import '../../data/provisioning_repository.dart';
import '../../../monitoring/data/repositories/monitoring_cache.dart';
import '../widgets/sensor_onboarding_flow.dart';
import '../widgets/device_detail/activation_dialog.dart';
import '../widgets/device_detail/delete_device_dialog.dart';
import '../widgets/device_detail/device_header_card.dart';
import '../widgets/device_detail/device_kpi_row.dart';
import '../widgets/device_detail/device_activation_button.dart';
import '../widgets/device_detail/sensor_list_tile.dart';
import 'sensor_details_route_page.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


class DeviceDetailPage extends StatefulWidget {
  const DeviceDetailPage({
    super.key,
    required this.role,
    required this.deviceId,
    required this.deviceName,
  });

  final UserRole role;
  final String deviceId;
  final String deviceName;

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  late final MonitoringRepository _repo;
  late final ProvisioningRepository _provRepo;

  late Future<List<DeviceWithSensorViewModel>> _rowsFuture;
  late Future<List<LatestSensorReadingViewModel>> _latestFuture;

  @override
  void initState() {
    super.initState();
    _repo = MonitoringRepository();
    _provRepo = ProvisioningRepository();
    _rowsFuture = _repo.fetchDevicesWithSensors();
    _latestFuture = _repo.fetchLatestSensorReadings();
  }

  // FIX AUDITORIA: _refresh() ahora solo se usa internamente después de acciones
  // específicas (crear sensor, eliminar dispositivo), NO para refresh manual.
  void _refresh() {
    setState(() {
      _rowsFuture = _repo.fetchDevicesWithSensors();
      _latestFuture = _repo.fetchLatestSensorReadings();
    });
  }

  Future<void> _showActivationDialog(String deviceUuid, String deviceName) async {
    await showActivationDialog(
      context: context,
      provRepo: _provRepo,
      deviceUuid: deviceUuid,
      deviceName: deviceName,
      onActivated: _refresh,
    );
  }

  Future<void> _showAddSensorModal(String deviceUuid, String deviceName) async {
    // Usar el nuevo flujo paso a paso
    final result = await SensorOnboardingFlow.show(
      context,
      deviceUuid: deviceUuid,
      deviceName: deviceName,
      onSensorCreated: _refresh,
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sensor registrado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showDeleteDeviceDialog(String deviceId, String deviceName) async {
    await showDeleteDeviceDialog(
      context: context,
      provRepo: _provRepo,
      deviceId: deviceId,
      deviceName: deviceName,
      onDeleted: _refresh,
    );
  }

  void _handleDeviceAction(String action, String deviceId, String deviceName) {
    switch (action) {
      case 'edit':
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edición de dispositivo próximamente')),
        );
        break;
      case 'delete':
        _showDeleteDeviceDialog(deviceId, deviceName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName),
        actions: [
          // FIX AUDITORIA: Eliminado refresh manual innecesario para evitar recargas
          // que causan sobrecarga UI y consumo excesivo de recursos.
          // La data se carga una vez y se mantiene estable.
          if (widget.role == UserRole.admin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Opciones',
              onSelected: (action) => _handleDeviceAction(action, widget.deviceId, widget.deviceName),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar dispositivo'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: DesignColors.red),
                      SizedBox(width: 8),
                      Text('Eliminar dispositivo', style: TextStyle(color: DesignColors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_rowsFuture, _latestFuture]),
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

          final rowsAll = data[0] as List<DeviceWithSensorViewModel>;
          final latestAll = data[1] as List<LatestSensorReadingViewModel>;

          final deviceRows = rowsAll.where((r) => r.deviceId == widget.deviceId).toList();
          if (deviceRows.isEmpty) {
            return const Center(child: Text('Dispositivo no encontrado.'));
          }

          final first = deviceRows.first;
          final latestBySensorId = <String, LatestSensorReadingViewModel>{
            for (final r in latestAll) r.sensorId: r,
          };

          final sensorRows = deviceRows.where((r) {
            if ((r.sensorId ?? '').isEmpty) return false;
            final status = (r.sensorStatus ?? '').toLowerCase();
            if (status == 'revoked') return false;
            return true;
          }).toList();
          final sensorIds = sensorRows.map((r) => r.sensorId!).toList();

          // Prefetch umbrales en segundo plano para los primeros 5 sensores visibles
          for (var i = 0; i < sensorRows.length && i < 5; i++) {
            final sid = sensorRows[i].sensorId;
            if (sid == null) continue;
            if (MonitoringCache.getThresholdProfileCache(sid) != null) continue;
            _repo.fetchSensorThresholdProfile(sid).then((profile) {
              MonitoringCache.setThresholdProfileCache(sid, profile);
              debugPrint('[Prefetch] Threshold profile cached for sensor $sid');
            }).catchError((e) {
              debugPrint('[Prefetch] Failed to load thresholds for $sid: $e');
            });
          }

          return FutureBuilder<Map<String, SensorConsolidatedStatusViewModel>>(
            future: sensorIds.isEmpty
                ? Future.value(const <String, SensorConsolidatedStatusViewModel>{})
                : _repo.fetchSensorStatusBatch(sensorIds),
            builder: (context, stSnap) {
              final bySensorId = stSnap.data ?? const <String, SensorConsolidatedStatusViewModel>{};

              int alerts = 0;
              int warnings = 0;
              int pending = 0;
              for (final sid in sensorIds) {
                final st = bySensorId[sid];
                if (st == null) continue;
                final fs = st.finalState.toLowerCase();
                if (fs == 'alert') alerts++;
                if (fs == 'warning') warnings++;
              }

              for (final row in sensorRows) {
                final status = row.deviceStatus.toLowerCase();
                final isActive = row.sensorActive == true;
                if (status == 'draft' ||
                    status == 'pending_claim' ||
                    status == 'pending_confirmation' ||
                    status == 'pending_activation' ||
                    !isActive) {
                  pending++;
                }
              }

              return ListView(
                padding: EdgeInsets.all(DesignSpacing.lg),
                children: [
                  DeviceHeaderCard(
                    deviceName: first.deviceName,
                    deviceType: first.deviceType,
                    deviceStatus: first.deviceStatus,
                    lastConnection: first.lastConnection,
                  ),
                  SizedBox(height: DesignSpacing.lg),
                  DeviceKpiRow(
                    sensorCount: sensorRows.length,
                    alerts: alerts,
                    warnings: warnings,
                    pending: pending,
                  ),
                  if (widget.role == UserRole.admin &&
                      (first.deviceStatus.toLowerCase() == 'draft' ||
                       first.deviceStatus.toLowerCase() == 'pending_activation')) ...[
                    SizedBox(height: DesignSpacing.lg),
                    DeviceActivationButton(
                      deviceStatus: first.deviceStatus,
                      deviceUuid: first.deviceUuid,
                      deviceName: first.deviceName,
                      onActivate: () => _showActivationDialog(first.deviceUuid, first.deviceName),
                    ),
                  ],
                  SizedBox(height: DesignSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sensores', style: DesignTextStyles.screenTitle),
                      if (widget.role == UserRole.admin)
                        TextButton.icon(
                          onPressed: () => _showAddSensorModal(first.deviceUuid, first.deviceName),
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text('Agregar'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.tealAccent,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: DesignSpacing.sm),
                  if (sensorRows.isEmpty)
                    Text('Sin sensores asociados.', style: DesignTextStyles.bodyText)
                  else
                    ...sensorRows.map((row) {
                      final sid = row.sensorId!;
                      final st = bySensorId[sid];
                      final latest = latestBySensorId[sid];

                      return SensorListTile(
                        row: row,
                        status: st,
                        latest: latest,
                        onTap: () async {
                          final result = await Navigator.of(context).pushNamed(
                            '/sensor/$sid',
                            arguments: SensorDetailsArgs(sensorId: sid),
                          );
                          if (result == 'deleted' && mounted) {
                            _refresh();
                          }
                        },
                      );
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
