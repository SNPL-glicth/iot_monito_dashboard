import 'package:intl/intl.dart';

/// Cleanup 4.2: Utilidades de fecha compartidas para evitar código duplicado.
/// 
/// Anteriormente estas funciones estaban duplicadas en:
/// - dashboard_page.dart
/// - sensor_detail_page.dart

/// Formatea un timestamp a formato legible.
/// 
/// Soporta:
/// - ISO-8601 (ej: 2025-12-15T19:40:45Z)
/// - Formato legible del backend (ej: 15/12/2025 14:33 o 15/12/2025 14:33:10)
String formatDateTimeShared(String? raw) {
  if (raw == null || raw.isEmpty) return '-';

  // 1) ISO
  final iso = DateTime.tryParse(raw);
  if (iso != null) {
    return DateFormat('dd/MM/yyyy HH:mm').format(iso.toLocal());
  }

  // 2) Formatos "humanos" (si el backend devuelve dd/MM/yyyy HH:mm)
  final candidates = <DateFormat>[
    DateFormat('dd/MM/yyyy HH:mm'),
    DateFormat('dd/MM/yyyy HH:mm:ss'),
  ];

  for (final f in candidates) {
    try {
      final dt = f.parseLoose(raw);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      // probar siguiente formato
    }
  }

  // Si no pudimos parsear, mostramos el valor original.
  return raw;
}

/// Intenta parsear un timestamp a DateTime.
/// Retorna null si no se puede parsear.
DateTime? tryParseDateTimeShared(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final iso = DateTime.tryParse(raw);
  if (iso != null) return iso;

  final candidates = <DateFormat>[
    DateFormat('dd/MM/yyyy HH:mm'),
    DateFormat('dd/MM/yyyy HH:mm:ss'),
  ];
  for (final f in candidates) {
    try {
      return f.parseLoose(raw);
    } catch (_) {
      // continue
    }
  }
  return null;
}

/// Cleanup 4.3: Traducción de tipos de sensor compartida.
/// 
/// Anteriormente duplicada en:
/// - dashboard_page.dart
/// - sensor_detail_page.dart
String sensorTypeLabelShared(String? raw) {
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
