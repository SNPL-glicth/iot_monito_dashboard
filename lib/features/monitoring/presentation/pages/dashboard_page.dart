import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../../core/lifecycle/app_lifecycle_service.dart';
import '../../../../core/notifications/notification_state_service.dart';
import '../../../../core/realtime/realtime_models.dart';
import '../../../../core/realtime/realtime_service.dart';
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
  StreamSubscription<RealtimeConnectionState>? _wsStateSubscription;

  // Fallback polling with backoff: 10s -> 15s -> 30s (max)
  static const List<int> _fallbackIntervalsSec = [10, 15, 30];
  int _fallbackIntervalIndex = 0;

  final _realtimeService = RealtimeService();

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
    _setupAdaptivePolling();

    _lifecyclePauseSub = AppLifecycleService().onAppPaused.listen((_) {
      _pollTimer?.cancel();
      _notificationService.stopPolling();
    });
    _lifecycleResumeSub = AppLifecycleService().onAppResumed.listen((_) {
      _setupAdaptivePolling();
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
    _wsStateSubscription?.cancel();
    super.dispose();
  }

  void _setupAdaptivePolling() {
    _wsStateSubscription?.cancel();
    _wsStateSubscription = _realtimeService.stateStream.listen((state) {
      switch (state) {
        case RealtimeConnectionState.connected:
          if (_pollTimer != null) {
            _pollTimer?.cancel();
            _pollTimer = null;
            _fallbackIntervalIndex = 0;
            debugPrint('[Dashboard] WS connected: polling paused');
          }
          break;
        case RealtimeConnectionState.disconnected:
        case RealtimeConnectionState.reconnecting:
          if (_pollTimer == null) {
            _startFallbackPolling();
            debugPrint('[Dashboard] WS disconnected: fallback polling started');
          }
          break;
        case RealtimeConnectionState.connecting:
          break;
      }
    });

    // Initial check: if not connected, start polling immediately
    if (!_realtimeService.isConnected && _pollTimer == null) {
      _startFallbackPolling();
    }
  }

  void _startFallbackPolling() {
    _pollTimer?.cancel();
    final intervalSec = _fallbackIntervalsSec[
        _fallbackIntervalIndex.clamp(0, _fallbackIntervalsSec.length - 1)];
    _pollTimer = Timer.periodic(Duration(seconds: intervalSec), (_) {
      if (!mounted) return;
      _refreshDevicesSection();
      _escalateFallbackInterval();
    });
  }

  void _escalateFallbackInterval() {
    if (_fallbackIntervalIndex < _fallbackIntervalsSec.length - 1) {
      _fallbackIntervalIndex++;
      final newInterval = _fallbackIntervalsSec[_fallbackIntervalIndex];
      debugPrint('[Dashboard] Polling backoff: ${newInterval}s');
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(Duration(seconds: newInterval), (_) {
        if (!mounted) return;
        _refreshDevicesSection();
      });
    }
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
