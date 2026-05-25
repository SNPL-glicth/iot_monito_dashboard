import '../../../data/models/device_with_sensor_view_model.dart';
import '../../../data/models/reading/latest_reading_models.dart';
import '../../../data/models/sensor_consolidated_status_view_model.dart';

class SectionSnapshot<T> {
  const SectionSnapshot({this.data, this.loading = false, this.error});

  final T? data;
  final bool loading;
  final String? error;

  SectionSnapshot<T> copyWith({T? data, bool? loading, String? error}) {
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
