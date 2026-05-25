import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../../core/lifecycle/app_lifecycle_service.dart';
import '../../../../core/notifications/notification_state_service.dart';
import '../../../notifications/data/notifications_repository.dart';
import '../../data/models/device_with_sensor_view_model.dart';
import '../../data/models/reading/latest_reading_models.dart';
import '../../data/models/sensor_consolidated_status_view_model.dart';
import '../../data/monitoring_repository.dart';
import '../styles/dashboard_styles.dart';
import '../widgets/dashboard/dashboard_access_denied.dart';
import '../widgets/dashboard/dashboard_body.dart';
import '../widgets/dashboard/dashboard_notification_button.dart';
import '../widgets/dashboard/dashboard_page_models.dart';

/// Pantalla principal del dashboard legacy (solo admin).
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.role});

  final UserRole role;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final MonitoringRepository _repository;
  late final NotificationsRepository _notificationsRepository;

  List<NotificationItem> _backendNotifications = [];

  final ValueNotifier<SectionSnapshot<DevicesSectionData>> _devicesSection =
      ValueNotifier<SectionSnapshot<DevicesSectionData>>(
    const SectionSnapshot<DevicesSectionData>(loading: true),
  );

  Timer? _pollTimer;
  final _notificationService = NotificationStateService();
  StreamSubscription<void>? _lifecyclePauseSub;
  StreamSubscription<void>? _lifecycleResumeSub;

  void _navigateToSensor(String sensorId) {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamed('/sensor/$sensorId');
  }

  @override
  void initState() {
    super.initState();
    _repository = MonitoringRepository();
    _notificationsRepository = NotificationsRepository();
    _refreshDevicesSection();
    _notificationService.startPolling();
    _startPolling();

    _lifecyclePauseSub = AppLifecycleService().onAppPaused.listen((_) {
      _pollTimer?.cancel();
      _notificationService.stopPolling();
    });
    _lifecycleResumeSub = AppLifecycleService().onAppResumed.listen((_) {
      _startPolling();
      _notificationService.startPolling();
      _refreshDevicesSection();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _notificationService.stopPolling();
    _lifecyclePauseSub?.cancel();
    _lifecycleResumeSub?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      _refreshDevicesSection();
    });
  }

  Future<void> _refreshDevicesSection() async {
    final current = _devicesSection.value;
    _devicesSection.value = current.data == null
        ? current.copyWith(loading: true, error: null)
        : current.copyWith(error: null);

    try {
      final results = await Future.wait([
        _repository.fetchDevicesWithSensors(),
        _repository.fetchLatestSensorReadings(),
      ]);
      final devices = results[0] as List<DeviceWithSensorViewModel>;
      final latest = results[1] as List<LatestSensorReadingViewModel>;

      final sensorIds = devices
          .map((d) => (d.sensorId ?? '').trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final statusBySensorId = sensorIds.isNotEmpty
          ? await _repository.fetchSensorStatusBatch(sensorIds)
          : <String, SensorConsolidatedStatusViewModel>{};

      _devicesSection.value = SectionSnapshot<DevicesSectionData>(
        data: DevicesSectionData(
          devices: devices,
          latestReadings: latest,
          statusBySensorId: statusBySensorId,
        ),
        loading: false,
      );
    } catch (e) {
      final after = _devicesSection.value;
      _devicesSection.value = after.copyWith(loading: false, error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = switch (widget.role) {
      UserRole.admin => 'Administrador global',
      UserRole.operator => 'Operador',
      UserRole.viewer => 'Usuario',
    };

    if (widget.role != UserRole.admin) return const DashboardAccessDenied();

    return Scaffold(
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
              child: Text(roleLabel, style: DashboardTextStyles.appBarRoleChip),
            ),
          ],
        ),
        actions: [
          DashboardNotificationButton(
            notifications: _backendNotifications,
            onMarkAsRead: (ids) async {
              if (ids.isEmpty) return;
              final success = await _notificationsRepository.markAsRead(ids);
              if (success && mounted) setState(() => _backendNotifications = []);
            },
            onSensorTap: _navigateToSensor,
          ),
        ],
      ),
      body: DashboardBody(devicesSection: _devicesSection),
    );
  }
}
