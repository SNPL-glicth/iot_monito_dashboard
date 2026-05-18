import '../../../core/network/api_client.dart';

/// Modelo de notificación del backend
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.source,
    this.sourceEventId,
    this.sensorId,
    this.sensorName,
    this.deviceName,
    required this.severity,
    required this.title,
    this.message,
    required this.createdAt,
    required this.isRead,
    this.occurrenceCount = 1,
    this.value,
  });

  final String id;
  final String source; // 'alert' | 'ml_event'
  final String? sourceEventId;
  final String? sensorId;
  final String? sensorName;
  final String? deviceName;
  final String severity; // 'critical' | 'warning' | 'info'
  final String title;
  final String? message;
  final DateTime createdAt;
  final bool isRead;
  
  /// Contador de ocurrencias (para deduplicación)
  final int occurrenceCount;
  
  /// Valor del sensor cuando ocurrió la notificación
  final double? value;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      source: json['source']?.toString() ?? 'alert',
      sourceEventId: json['sourceEventId']?.toString(),
      sensorId: json['sensorId']?.toString(),
      sensorName: json['sensorName']?.toString(),
      deviceName: json['deviceName']?.toString(),
      severity: json['severity']?.toString() ?? 'info',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      isRead: json['isRead'] == true,
      occurrenceCount: (json['occurrenceCount'] as int?) ?? 1,
      value: (json['value'] as num?)?.toDouble(),
    );
  }
  
  /// Crea una copia con contador incrementado
  NotificationItem copyWithIncrementedCount() {
    return NotificationItem(
      id: id,
      source: source,
      sourceEventId: sourceEventId,
      sensorId: sensorId,
      sensorName: sensorName,
      deviceName: deviceName,
      severity: severity,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: isRead,
      occurrenceCount: occurrenceCount + 1,
      value: value,
    );
  }
  
  /// Key única para deduplicación (mismo sensor + mismo tipo + mismo valor aproximado)
  String get deduplicationKey {
    final valueKey = value != null ? value!.toStringAsFixed(1) : 'null';
    return '$sensorId|$source|$severity|$valueKey';
  }
}

/// Repositorio para manejar notificaciones del backend.
/// 
/// FIX AUDITORIA PROBLEMA 6: Implementa funcionalidad de marcar como leídas
/// para evitar acumulación infinita de notificaciones.
class NotificationsRepository {
  static final NotificationsRepository _instance = NotificationsRepository._internal();
  
  factory NotificationsRepository([ApiClient? apiClient]) => _instance;
  
  NotificationsRepository._internal() : _apiClient = ApiClient();

  final ApiClient _apiClient;

  /// Obtiene notificaciones no leídas del backend.
  Future<List<NotificationItem>> fetchUnreadNotifications({int limit = 100}) async {
    try {
      final rawList = await _apiClient.getList('/notifications/unread?limit=$limit');
      
      return rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => NotificationItem.fromJson(json))
          .toList();
    } catch (e) {
      // Si falla, retornar lista vacía para no romper UI
      return [];
    }
  }

  /// Marca notificaciones como leídas.
  /// 
  /// Debe llamarse cuando el usuario abre el modal de la campana.
  Future<bool> markAsRead(List<String> ids) async {
    if (ids.isEmpty) return true;
    
    try {
      await _apiClient.postJson('/notifications/mark-read', {'ids': ids});
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Marca TODAS las notificaciones no leídas como leídas.
  Future<bool> markAllAsRead() async {
    try {
      final unread = await fetchUnreadNotifications();
      if (unread.isEmpty) return true;
      
      final ids = unread.map((n) => n.id).toList();
      return markAsRead(ids);
    } catch (e) {
      return false;
    }
  }
  
  /// Limpia TODAS las notificaciones (marca como leídas y elimina del cache local)
  Future<bool> clearAllNotifications() async {
    try {
      await _apiClient.postJson('/notifications/clear-all', {});
      return true;
    } catch (e) {
      // Fallback: marcar todas como leídas
      return markAllAsRead();
    }
  }
  
  /// Deduplica notificaciones: agrupa las que tienen el mismo sensor + tipo + valor
  /// y muestra contador de ocurrencias
  List<NotificationItem> deduplicateNotifications(List<NotificationItem> notifications) {
    if (notifications.isEmpty) return [];
    
    final Map<String, NotificationItem> dedupMap = {};
    
    for (final n in notifications) {
      final key = n.deduplicationKey;
      if (dedupMap.containsKey(key)) {
        // Incrementar contador
        dedupMap[key] = dedupMap[key]!.copyWithIncrementedCount();
      } else {
        dedupMap[key] = n;
      }
    }
    
    // Ordenar por fecha más reciente
    final result = dedupMap.values.toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return result;
  }
  
  /// Filtra notificaciones ML para evitar spam (máx 2 repeticiones del mismo patrón)
  List<NotificationItem> filterMLNotifications(List<NotificationItem> notifications) {
    final mlNotifications = notifications.where((n) => n.source == 'ml_event').toList();
    final otherNotifications = notifications.where((n) => n.source != 'ml_event').toList();
    
    // Agrupar ML por sensor
    final Map<String, List<NotificationItem>> mlBySensor = {};
    for (final n in mlNotifications) {
      final key = n.sensorId ?? 'unknown';
      mlBySensor.putIfAbsent(key, () => []).add(n);
    }
    
    // Limitar a máx 2 por sensor
    final filteredML = <NotificationItem>[];
    for (final entry in mlBySensor.entries) {
      final sorted = entry.value..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      filteredML.addAll(sorted.take(2));
    }
    
    return [...otherNotifications, ...filteredML]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
