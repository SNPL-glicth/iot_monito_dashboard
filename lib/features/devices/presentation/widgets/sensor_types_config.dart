import 'package:flutter/material.dart';

/// Configuración de tipos de sensores disponibles
class SensorTypesConfig {
  static const List<Map<String, dynamic>> sensorTypes = [
    {'type': 'temperature', 'label': 'Temperatura', 'unit': '°C', 'icon': Icons.thermostat},
    {'type': 'humidity', 'label': 'Humedad', 'unit': '%', 'icon': Icons.water_drop},
    {'type': 'pressure', 'label': 'Presión', 'unit': 'hPa', 'icon': Icons.compress},
    {'type': 'voltage', 'label': 'Voltaje', 'unit': 'V', 'icon': Icons.bolt},
    {'type': 'current', 'label': 'Corriente', 'unit': 'A', 'icon': Icons.electric_bolt},
    {'type': 'power', 'label': 'Potencia', 'unit': 'W', 'icon': Icons.power},
    {'type': 'level', 'label': 'Nivel', 'unit': '%', 'icon': Icons.signal_cellular_alt},
    {'type': 'flow', 'label': 'Flujo', 'unit': 'L/min', 'icon': Icons.waves},
  ];

  static Map<String, dynamic> getType(String selectedType) {
    return sensorTypes.firstWhere(
      (t) => t['type'] == selectedType,
      orElse: () => sensorTypes[0],
    );
  }

  static IconData getIcon(String selectedType) {
    return getType(selectedType)['icon'] as IconData;
  }

  static String getLabel(String selectedType) {
    return getType(selectedType)['label'] as String;
  }

  static String getUnit(String selectedType) {
    return getType(selectedType)['unit'] as String;
  }
}
