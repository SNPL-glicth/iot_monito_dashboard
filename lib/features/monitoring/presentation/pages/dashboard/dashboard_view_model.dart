import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../notifications/data/notifications_repository.dart';
import '../../../data/monitoring_repository.dart';
import '../../../data/models/monitoring_view_models.dart';
import '../../../data/models/sensor_consolidated_status_view_model.dart';
import '../../../data/models/device_with_sensor_view_model.dart';
import '../../../data/models/reading/latest_reading_models.dart';
import '../../../../../core/notifications/notification_state_service.dart';

/// ViewModel for dashboard page state management
class DashboardViewModel {
  DashboardViewModel({
    required this.onStateChanged,
  });

  final Function() onStateChanged;
  final _repository = MonitoringRepository();
  final _notificationsRepository = NotificationsRepository();
  final _notificationService = NotificationStateService();

  Timer? _pollTimer;

  // State
  final ValueNotifier<SectionSnapshot<DevicesSectionData>> devicesSection =
      ValueNotifier<SectionSnapshot<DevicesSectionData>>(
    const SectionSnapshot<DevicesSectionData>(loading: true),
  );

  List<NotificationItem> backendNotifications = [];

  ValueNotifier<SectionSnapshot<DevicesSectionData>> get devicesSectionNotifier => devicesSection;
  List<NotificationItem> get notifications => backendNotifications;

  void dispose() {
    _pollTimer?.cancel();
    _notificationService.stopPolling();
    devicesSection.dispose();
  }

  void startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      refreshDevicesSection();
    });
  }

  void startNotificationPolling() {
    _notificationService.startPolling();
  }

  Future<void> refreshDevicesSection() async {
    final current = devicesSection.value;
    if (current.data == null) {
      devicesSection.value = current.copyWith(loading: true, error: null);
    } else {
      devicesSection.value = current.copyWith(error: null);
    }

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

      devicesSection.value = SectionSnapshot<DevicesSectionData>(
        data: DevicesSectionData(
          devices: devices,
          latestReadings: latest,
          statusBySensorId: statusBySensorId,
        ),
        loading: false,
      );
    } catch (e) {
      final after = devicesSection.value;
      devicesSection.value = after.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> markNotificationsAsRead() async {
    if (backendNotifications.isEmpty) return;
    
    final ids = backendNotifications.map((n) => n.id).toList();
    final success = await _notificationsRepository.markAsRead(ids);
    
    if (success) {
      backendNotifications = [];
      onStateChanged();
    }
  }

  void setNotifications(List<NotificationItem> notifications) {
    backendNotifications = notifications;
    onStateChanged();
  }
}

class SectionSnapshot<T> {
  const SectionSnapshot({
    this.data,
    this.loading = false,
    this.error,
  });

  final T? data;
  final bool loading;
  final String? error;

  SectionSnapshot<T> copyWith({
    T? data,
    bool? loading,
    String? error,
  }) {
    return SectionSnapshot<T>(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class DevicesSectionData {
  const DevicesSectionData({
    required this.devices,
    required this.latestReadings,
    required this.statusBySensorId,
  });

  final List<DeviceWithSensorViewModel> devices;
  final List<LatestSensorReadingViewModel> latestReadings;
  final Map<String, SensorConsolidatedStatusViewModel> statusBySensorId;
}
