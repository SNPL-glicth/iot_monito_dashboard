/// Tipo de fuente de la notificación
enum NotificationSource {
  alert, // Alerta por umbral (prioridad alta)
  mlEvent, // Evento ML (prioridad baja)
  system, // Sistema
}

/// Severidad de la notificación
enum NotificationSeverity {
  critical, // Rojo intenso
  warning, // Naranja
  notice, // Amarillo
  info, // Azul
}

/// Modelo de notificación unificado
class AppNotification {
  const AppNotification({
    required this.id,
    required this.source,
    required this.sourceEventId,
    required this.severity,
    required this.title,
    this.message,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.sensorId,
    this.sensorName,
    this.deviceName,
  });

  final String id;
  final NotificationSource source;
  final String? sourceEventId;
  final NotificationSeverity severity;
  final String title;
  final String? message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? sensorId;
  final String? sensorName;
  final String? deviceName;

  /// Prioridad numérica (menor = más prioritario)
  int get priority {
    if (source == NotificationSource.alert) {
      switch (severity) {
        case NotificationSeverity.critical:
          return 0;
        case NotificationSeverity.warning:
          return 1;
        case NotificationSeverity.notice:
          return 2;
        case NotificationSeverity.info:
          return 3;
      }
    }
    return 10 + severity.index;
  }

  /// Color según tipo y severidad
  int get colorValue {
    if (source == NotificationSource.alert) {
      switch (severity) {
        case NotificationSeverity.critical:
          return 0xFFEF4444;
        case NotificationSeverity.warning:
          return 0xFFF97316;
        case NotificationSeverity.notice:
          return 0xFFEAB308;
        case NotificationSeverity.info:
          return 0xFF3B82F6;
      }
    }
    return 0xFFA855F7;
  }

  AppNotification copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
      source: source,
      sourceEventId: sourceEventId,
      severity: severity,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      sensorId: sensorId,
      sensorName: sensorName,
      deviceName: deviceName,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    NotificationSource parseSource(String? s) {
      switch (s?.toLowerCase()) {
        case 'alert':
          return NotificationSource.alert;
        case 'ml_event':
          return NotificationSource.mlEvent;
        default:
          return NotificationSource.system;
      }
    }

    NotificationSeverity parseSeverity(String? s) {
      switch (s?.toLowerCase()) {
        case 'critical':
          return NotificationSeverity.critical;
        case 'warning':
          return NotificationSeverity.warning;
        case 'notice':
          return NotificationSeverity.notice;
        default:
          return NotificationSeverity.info;
      }
    }

    return AppNotification(
      id: json['id']?.toString() ?? '',
      source: parseSource(json['source'] as String?),
      sourceEventId: json['sourceEventId']?.toString(),
      severity: parseSeverity(json['severity'] as String?),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString(),
      isRead: json['isRead'] == true || json['isRead'] == 1,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt'].toString()) : null,
      sensorId: json['sensorId']?.toString(),
      sensorName: json['sensorName']?.toString(),
      deviceName: json['deviceName']?.toString(),
    );
  }
}
