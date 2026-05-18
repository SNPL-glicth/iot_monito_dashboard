import 'package:flutter/material.dart';

/// Configuración estática de tipos de sensores soportados.
final List<Map<String, dynamic>> sensorTypesData = [
  {
    'value': 'temperature',
    'label': 'Temperatura',
    'icon': Icons.thermostat,
    'unit': '°C',
    'defaultWarning': [15.0, 30.0],
    'defaultAlert': [10.0, 35.0],
  },
  {
    'value': 'humidity',
    'label': 'Humedad',
    'icon': Icons.water_drop,
    'unit': '%',
    'defaultWarning': [30.0, 70.0],
    'defaultAlert': [20.0, 80.0],
  },
  {
    'value': 'pressure',
    'label': 'Presión',
    'icon': Icons.compress,
    'unit': 'hPa',
    'defaultWarning': [980.0, 1030.0],
    'defaultAlert': [960.0, 1050.0],
  },
  {
    'value': 'voltage',
    'label': 'Voltaje',
    'icon': Icons.bolt,
    'unit': 'V',
    'defaultWarning': [110.0, 130.0],
    'defaultAlert': [100.0, 140.0],
  },
  {
    'value': 'current',
    'label': 'Corriente',
    'icon': Icons.electric_meter,
    'unit': 'A',
    'defaultWarning': [0.0, 15.0],
    'defaultAlert': [0.0, 20.0],
  },
  {
    'value': 'power',
    'label': 'Potencia',
    'icon': Icons.power,
    'unit': 'W',
    'defaultWarning': [0.0, 1000.0],
    'defaultAlert': [0.0, 1500.0],
  },
  {
    'value': 'air_quality',
    'label': 'Calidad de Aire',
    'icon': Icons.air,
    'unit': 'ppm',
    'defaultWarning': [0.0, 400.0],
    'defaultAlert': [0.0, 600.0],
  },
  {
    'value': 'ph',
    'label': 'pH',
    'icon': Icons.science,
    'unit': 'pH',
    'defaultWarning': [6.5, 8.5],
    'defaultAlert': [6.0, 9.0],
  },
];
