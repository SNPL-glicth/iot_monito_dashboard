import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../features/monitoring/data/models/device_with_sensor_view_model.dart';
import '../../../../../features/monitoring/data/models/monitoring_view_models.dart';

enum DeviceTypeFilter {
  all,
  environmental,
  refrigeration,
  electric,
}

enum SensorCategory {
  electricity,
  environmental,
  temperature,
}

extension DeviceFilterHelpers on DeviceTypeFilter {
  String get label {
    switch (this) {
      case DeviceTypeFilter.all:
        return 'Todos';
      case DeviceTypeFilter.environmental:
        return 'Ambiental';
      case DeviceTypeFilter.refrigeration:
        return 'Refrigeración';
      case DeviceTypeFilter.electric:
        return 'Eléctrico';
    }
  }

  IconData get icon {
    switch (this) {
      case DeviceTypeFilter.all:
        return Icons.dashboard_outlined;
      case DeviceTypeFilter.environmental:
        return Icons.thermostat_outlined;
      case DeviceTypeFilter.refrigeration:
        return Icons.ac_unit_outlined;
      case DeviceTypeFilter.electric:
        return Icons.electrical_services_outlined;
    }
  }

  bool matches(String rawType) {
    if (this == DeviceTypeFilter.all) return true;
    final t = rawType.toLowerCase();
    bool any(List<String> needles) => needles.any((n) => t.contains(n));
    switch (this) {
      case DeviceTypeFilter.environmental:
        return any(['ambient', 'clima', 'environment']);
      case DeviceTypeFilter.refrigeration:
        return any(['frigo', 'refrig', 'refrigerator', 'cold']);
      case DeviceTypeFilter.electric:
        return any(['electric', 'electr', 'energy', 'meter', 'power']);
      case DeviceTypeFilter.all:
        return true;
    }
  }
}

extension SensorCategoryHelpers on SensorCategory {
  String get title {
    switch (this) {
      case SensorCategory.electricity:
        return 'Sensores de Electricidad';
      case SensorCategory.environmental:
        return 'Sensores Ambientales';
      case SensorCategory.temperature:
        return 'Sensores de Temperatura';
    }
  }
}

String sensorTypeLabel(String? raw) {
  if (raw == null) return '-';
  switch (raw.toLowerCase()) {
    case 'temperature':
      return 'temperatura';
    case 'humidity':
      return 'humedad';
    case 'air_quality':
      return 'calidad del aire';
    case 'power':
      return 'potencia';
    case 'voltage':
      return 'voltaje';
    default:
      return raw;
  }
}

String deviceTypeLabel(String raw) {
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

SensorCategory sensorCategoryOf(String? raw) {
  final t = (raw ?? '').toLowerCase().trim();
  if (t == 'temperature' || t.contains('temp')) {
    return SensorCategory.temperature;
  }
  if (t == 'voltage' || t == 'power' || t.contains('electric') || t.contains('energy')) {
    return SensorCategory.electricity;
  }
  if (t == 'humidity' || t == 'air_quality' || t.contains('air') || t.contains('humid')) {
    return SensorCategory.environmental;
  }
  return SensorCategory.environmental;
}

String formatDateTime(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  final iso = DateTime.tryParse(raw);
  if (iso != null) {
    return DateFormat('dd/MM/yyyy HH:mm').format(iso.toLocal());
  }
  final candidates = <DateFormat>[
    DateFormat('dd/MM/yyyy HH:mm'),
    DateFormat('dd/MM/yyyy HH:mm:ss'),
  ];
  for (final f in candidates) {
    try {
      final dt = f.parseLoose(raw);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      // seguir
    }
  }
  return raw;
}

DeviceWithSensorViewModel? pickRepresentative(
  List<DeviceWithSensorViewModel> list,
  Map<String, LatestSensorReadingViewModel> latestBySensorId,
) {
  if (list.isEmpty) return null;
  int score(DeviceWithSensorViewModel r) {
    var s = 0;
    if (r.sensorActive == true) s += 10;
    if (r.deviceStatus.toLowerCase() == 'online') s += 5;
    final sid = r.sensorId;
    if (sid != null && latestBySensorId.containsKey(sid)) s += 3;
    return s;
  }
  final sorted = [...list]..sort((a, b) => score(b).compareTo(score(a)));
  return sorted.first;
}
