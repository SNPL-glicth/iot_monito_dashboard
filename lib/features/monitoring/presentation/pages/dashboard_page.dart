import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/auth/auth_storage.dart';
import '../../../../core/auth/user_role.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/notifications/notification_state_service.dart';
import '../../../../core/realtime/realtime_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../devices/presentation/pages/sensor_details_route_page.dart';
import '../../../notifications/data/notifications_repository.dart';
import '../../data/models/device_with_sensor_view_model.dart';
import '../../data/models/reading/latest_reading_models.dart';
import '../../data/models/sensor_consolidated_status_view_model.dart';
import '../../data/monitoring_repository.dart';
import '../styles/dashboard_styles.dart';
import '../widgets/dashboard/dashboard_devices_section.dart';
import '../widgets/dashboard/dashboard_notification_button.dart';
import '../widgets/dashboard/dashboard_readings_section.dart';

// pantalla principal del dashboard de la app
class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.role,
  });

  final UserRole role;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _SectionSnapshot<T> {
  const _SectionSnapshot({
    this.data,
    this.loading = false,
    this.error,
  });

  final T? data;
  final bool loading;
  final String? error;

  _SectionSnapshot<T> copyWith({
    T? data,
    bool? loading,
    String? error,
  }) {
    return _SectionSnapshot<T>(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class _DevicesSectionData {
  const _DevicesSectionData({
    required this.devices,
    required this.latestReadings,
    required this.statusBySensorId,
  });

  final List<DeviceWithSensorViewModel> devices;
  final List<LatestSensorReadingViewModel> latestReadings;

  /// Status consolidado por sensor_id (snake_case del backend, ya parseado).
  final Map<String, SensorConsolidatedStatusViewModel> statusBySensorId;
}

class _DashboardPageState extends State<DashboardPage> {
  late final MonitoringRepository _repository;
  late final NotificationsRepository _notificationsRepository;

  
  // FIX AUDITORIA PROBLEMA 6: Cache de notificaciones del backend
  List<NotificationItem> _backendNotifications = [];

  // Estado reactivo por sección
  final ValueNotifier<_SectionSnapshot<_DevicesSectionData>> _devicesSection =
      ValueNotifier<_SectionSnapshot<_DevicesSectionData>>(
    const _SectionSnapshot<_DevicesSectionData>(loading: true),
  );

  Timer? _pollTimer;
  final NotificationStateService _notificationService = NotificationStateService();



  /// Navega a la página de detalle de un sensor.
  void _navigateToSensor(String sensorId) {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamed(
      '/sensor/$sensorId',
      arguments: SensorDetailsArgs(sensorId: sensorId),
    );
  }

  @override
  void initState() {// donde se mira lo de Machine Learning pero ta complicado
    super.initState();
    _repository = MonitoringRepository();
    _notificationsRepository = NotificationsRepository();

    // Carga inicial de todas las secciones
    _refreshDevicesSection();
    
    // BUG-2 FIX: Usar polling centralizado en lugar de timer local
    _notificationService.startPolling();
    
    // Mantener polling local solo para devices (no para notificaciones)
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _notificationService.stopPolling();
    super.dispose();
  }

  void _startPolling() {
    // BUG-2 FIX: Polling solo para devices, notificaciones usan servicio centralizado
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      _refreshDevicesSection();
      // _loadBackendNotifications() removido - servicio centralizado maneja notificaciones
    });
  }

  Future<void> _refreshDevicesSection() async {
    final current = _devicesSection.value;
    if (current.data == null) {
      _devicesSection.value =
          current.copyWith(loading: true, error: null);
    } else {
      _devicesSection.value = current.copyWith(error: null);
    }

    try {
      final results = await Future.wait([
        _repository.fetchDevicesWithSensors(),
        _repository.fetchLatestSensorReadings(),
      ]);
      final devices = results[0] as List<DeviceWithSensorViewModel>;
      final latest = results[1] as List<LatestSensorReadingViewModel>;

      // Perf 2.1: Obtener status consolidado por sensor usando endpoint batch.
      // Esto elimina el problema N+1 donde se hacía 1 request por sensor.
      // Flutter no interpreta lógica: solo pinta final_state y bloques si existen.
      final sensorIds = devices
          .map((d) => (d.sensorId ?? '').trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final statusBySensorId = sensorIds.isNotEmpty
          ? await _repository.fetchSensorStatusBatch(sensorIds)
          : <String, SensorConsolidatedStatusViewModel>{};

      _devicesSection.value = _SectionSnapshot<_DevicesSectionData>(
        data: _DevicesSectionData(
          devices: devices,
          latestReadings: latest,
          statusBySensorId: statusBySensorId,
        ),
        loading: false,
      );
    } catch (e) {
      final after = _devicesSection.value;
      _devicesSection.value =
          after.copyWith(loading: false, error: e.toString());
    }
  }

  // _finalStateColor, _finalStateLabel, _refreshAlertsSection removed - unused

  @override
  Widget build(BuildContext context) {
    // Etiqueta de rol (evita confusiones en UI)
    final String roleLabel;
    switch (widget.role) {
      case UserRole.admin:
        roleLabel = 'Administrador global';
        break;
      case UserRole.operator:
        roleLabel = 'Operador';
        break;
      case UserRole.viewer:
        roleLabel = 'Usuario';
        break;
    }

    // Seguridad UI: este dashboard es SOLO para admin.
    // Si por alguna razón un operador cae aquí (rol mal devuelto por backend o build viejo), no mostramos info admin.
    if (widget.role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acceso restringido')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Este dashboard es solo para administradores.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    ApiClient.authToken = null;
                    await AuthStorage().clearSession();
                    // FIX REALTIME: Desconectar WebSocket al cerrar sesión
                    RealtimeService().disconnect();
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Volver al login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      // REMOVED: Legacy offcanvas - using unified alert system instead
      // drawer: _buildMainDrawer(context, roleLabel),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text('IoT Monitoring', style: DashboardTextStyles.appBarTitle),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                roleLabel,
                style: DashboardTextStyles.appBarRoleChip,
              ),
            ),
          ],
        ),
        actions: [
          DashboardNotificationButton(
            notifications: _backendNotifications,
            onMarkAsRead: (ids) async {
              if (ids.isEmpty) return;
              final success = await _notificationsRepository.markAsRead(ids);
              if (success && mounted) {
                setState(() {
                  _backendNotifications = [];
                });
              }
            },
            onSensorTap: _navigateToSensor,
          ),
        ],
      ),
      body: LayoutBuilder(//los tamaños del layout de que ancho y tamaño son 
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final horizontalPadding = isWide ? constraints.maxWidth * 0.15 : 16.0;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<_SectionSnapshot<_DevicesSectionData>>(
                      valueListenable: _devicesSection,
                      builder: (context, snapshot, _) {
                        if (snapshot.loading && snapshot.data == null) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.error != null && snapshot.data == null) {
                          return Text('Error: ${snapshot.error}');
                        }
                        final data = snapshot.data;
                        if (data == null || data.devices.isEmpty) {
                          return const Text('No hay dispositivos registrados.');
                        }
                        return DashboardDevicesSection(
                          devices: data.devices,
                          latestReadings: data.latestReadings,
                          statusBySensorId: data.statusBySensorId,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<_SectionSnapshot<_DevicesSectionData>>(
                      valueListenable: _devicesSection,
                      builder: (context, snapshot, _) {
                        if (snapshot.loading && snapshot.data == null) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.error != null && snapshot.data == null) {
                          return Text('Error: ${snapshot.error}', style: DashboardTextStyles.error);
                        }
                        final readings = snapshot.data?.latestReadings ?? const <LatestSensorReadingViewModel>[];
                        return DashboardReadingsSection(readings: readings);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  // _buildMainDrawer, _showUserInfoDialog, _confirmLogout, _buildAdminManagementSection removed - unused
  // Navigation is now handled via AppBar actions and bottom navigation
}
