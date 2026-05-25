import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/lifecycle/app_lifecycle_service.dart';
import '../../data/monitoring_repository.dart';
import '../../data/models/device_with_sensor_view_model.dart';
import '../../data/models/reading/latest_reading_models.dart';
import '../../data/models/sensor_consolidated_status_view_model.dart';
import 'dashboard_state.dart';

/// Cubit para manejar el estado del dashboard.
///
/// Responsabilidades:
/// - Carga de dispositivos y sensores
/// - Estado reactivo por sección
/// - Polling de datos
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required MonitoringRepository repository,
    Duration pollingInterval = const Duration(seconds: 30),
  })  : _repository = repository,
        _pollingInterval = pollingInterval,
        super(const DashboardInitial()) {
    _pollTimer = null;
    _lifecyclePauseSub = AppLifecycleService().onAppPaused.listen((_) {
      stopPolling();
    });
    _lifecycleResumeSub = AppLifecycleService().onAppResumed.listen((_) {
      startPolling();
    });
  }

  final MonitoringRepository _repository;
  final Duration _pollingInterval;
  Timer? _pollTimer;
  StreamSubscription<void>? _lifecyclePauseSub;
  StreamSubscription<void>? _lifecycleResumeSub;

  /// Carga inicial de dispositivos
  Future<void> loadDevices() async {
    emit(const DashboardLoading());

    try {
      final results = await Future.wait([
        _repository.fetchDevicesWithSensors(),
        _repository.fetchLatestSensorReadings(),
      ]);
      final devices = results[0] as List<DeviceWithSensorViewModel>;
      final latest = results[1] as List<LatestSensorReadingViewModel>;

      final sensorIds = devices
          .map((d) => d.sensorId ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final statusBySensorId = sensorIds.isNotEmpty
          ? await _repository.fetchSensorStatusBatch(sensorIds)
          : <String, SensorConsolidatedStatusViewModel>{};

      emit(DashboardLoaded(
        devices: devices,
        latestReadings: latest,
        statusBySensorId: statusBySensorId,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  /// Inicia el polling automático
  void startPolling() {
    stopPolling();
    loadDevices(); // Carga inicial
    _pollTimer = Timer.periodic(_pollingInterval, (_) {
      loadDevices();
    });
  }

  /// Detiene el polling
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Future<void> close() {
    stopPolling();
    _lifecyclePauseSub?.cancel();
    _lifecycleResumeSub?.cancel();
    return super.close();
  }
}
