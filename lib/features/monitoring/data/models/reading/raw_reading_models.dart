/// Lectura individual cruda sin agregación
class RawReadingItem {
  RawReadingItem({
    required this.id,
    required this.value,
    required this.timestamp,
    required this.timestampFormatted,
  });

  final String id;
  final double value;
  final String timestamp;
  final String timestampFormatted;

  factory RawReadingItem.fromJson(Map<String, dynamic> json) {
    return RawReadingItem(
      id: json['id']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp']?.toString() ?? '',
      timestampFormatted: json['timestampFormatted']?.toString() ?? '',
    );
  }
}

/// Payload de lecturas crudas de un sensor
class RawSensorReadingsViewModel {
  RawSensorReadingsViewModel({
    required this.sensorId,
    required this.sensorName,
    required this.deviceName,
    required this.unit,
    required this.count,
    required this.readings,
  });

  final String sensorId;
  final String sensorName;
  final String deviceName;
  final String unit;
  final int count;
  final List<RawReadingItem> readings;

  factory RawSensorReadingsViewModel.fromJson(Map<String, dynamic> json) {
    final readingsList = (json['readings'] as List<dynamic>?)
        ?.map((e) => RawReadingItem.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return RawSensorReadingsViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      sensorName: json['sensorName']?.toString() ?? '',
      deviceName: json['deviceName']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      readings: readingsList,
    );
  }
}
