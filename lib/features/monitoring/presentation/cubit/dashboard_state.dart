import 'package:equatable/equatable.dart';

import '../../data/models/device_with_sensor_view_model.dart';
import '../../data/models/monitoring_view_models.dart';
import '../../data/models/sensor_consolidated_status_view_model.dart';

/// Estado base del Dashboard
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Estado de carga
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Estado con datos cargados
class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.devices,
    required this.latestReadings,
    required this.statusBySensorId,
  });

  final List<DeviceWithSensorViewModel> devices;
  final List<LatestSensorReadingViewModel> latestReadings;
  final Map<String, SensorConsolidatedStatusViewModel> statusBySensorId;

  @override
  List<Object?> get props => [devices, latestReadings, statusBySensorId];
}

/// Estado de error
class DashboardError extends DashboardState {
  const DashboardError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
