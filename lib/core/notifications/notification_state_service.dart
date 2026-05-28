/// Servicio de estado de notificaciones - REFACTOR ESTRUCTURAL.
/// 
/// ARQUITECTURA:
/// - SSOT = Base de datos (siempre)
/// - SIN CACHE local (eliminado para evitar inconsistencias)
/// - Patrón REACTIVO puro: Widget escucha streams, nunca lee sync
/// - Todas las operaciones son async y emiten al completar
/// 
/// FLUJOS DETERMINISTAS:
/// 1. fetch() → API → actualiza estado → emite stream
/// 2. markAsRead() → API → fetch() → emite stream
/// 3. Widget SOLO escucha streams, NUNCA lee getters sync en build()
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../lifecycle/app_lifecycle_service.dart';
import '../network/api_client.dart';
import '../realtime/realtime_models.dart';
import '../realtime/realtime_service.dart';
import 'models/app_notification.dart';
import 'models/notification_state.dart';

export 'models/app_notification.dart';
export 'models/notification_state.dart';


/// Servicio singleton para gestionar estado de notificaciones.
/// 
/// ARQUITECTURA REACTIVA PURA:
/// - Un único stream de estado (NotificationState)
/// - Widget SOLO escucha el stream, NUNCA lee getters sync
/// - Todas las operaciones son async y emiten nuevo estado al completar
/// - SIN CACHE - siempre consulta DB (con debounce para evitar spam)
/// 
/// CONTRATO:
/// - fetch() → siempre consulta API → emite nuevo estado
/// - markAsRead() → API → fetch() → emite nuevo estado
/// - El widget DEBE usar StreamBuilder, no getters
class NotificationStateService {
  final ApiClient _api = ApiClient();
  final RealtimeService _realtimeService = RealtimeService();
  StreamSubscription? _realtimeStateSubscription;
  
  // Estado actual - SOLO se modifica via _emit()
  NotificationState _state = NotificationState.empty;
  
  // Stream controller único para todo el estado
  final _stateController = StreamController<NotificationState>.broadcast();
  
  // Debounce para evitar fetches simultáneos
  Completer<void>? _fetchCompleter;
  
  // Polling timer (singleton global para evitar duplicación)
  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 10);
  
  // Configuración
  static const int _maxNotifications = 100;
  static const bool _enableLogs = true;

  // Singleton
  static final NotificationStateService _instance = NotificationStateService._internal();
  factory NotificationStateService() => _instance;
  NotificationStateService._internal() {
    _log('Service initialized');
    _setupWebSocketAwareness();
    _setupLifecycleAwareness();
  }

  void _setupLifecycleAwareness() {
    AppLifecycleService().onAppPaused.listen((_) {
      _log('App paused - stopping notification polling');
      stopPolling();
    });
    AppLifecycleService().onAppResumed.listen((_) {
      _log('App resumed - starting notification polling');
      startPolling();
    });
  }

  /// Configura awareness de WebSocket para detener/iniciar polling automáticamente
  void _setupWebSocketAwareness() {
    // Escuchar cambios de estado de conexión
    _realtimeStateSubscription = _realtimeService.stateStream.listen((state) {
      if (state == RealtimeConnectionState.connected) {
        _log('WebSocket connected - stopping polling');
        stopPolling();
      } else if (state == RealtimeConnectionState.disconnected) {
        _log('WebSocket disconnected - starting polling as fallback');
        startPolling();
      }
    });

    // Escuchar eventos de realtime y sincronizar notificaciones
    _realtimeService.eventStream.listen((event) {
      if (event.type == RealtimeEventType.alertsActive ||
          event.type == RealtimeEventType.mlEventsActive) {
        _log('Realtime event received: ${event.type} - syncing notifications');
        _debouncedFetchNotifications();
      }
    });
  }

  Timer? _debounceTimer;

  void _debouncedFetchNotifications() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      fetchNotifications();
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // STREAMS - La ÚNICA forma de obtener datos para UI
  // ═══════════════════════════════════════════════════════════════════

  /// Stream del estado completo - USAR ESTE EN WIDGETS
  Stream<NotificationState> get stateStream => _stateController.stream;

  /// Estado actual (para lectura inicial en StreamBuilder)
  NotificationState get currentState => _state;

  // ═══════════════════════════════════════════════════════════════════
  // GETTERS LEGACY - Mantener por compatibilidad, pero preferir stream
  // ═══════════════════════════════════════════════════════════════════
  
  /// @deprecated Usar stateStream en su lugar
  Stream<List<AppNotification>> get notificationsStream => 
      _stateController.stream.map((s) => s.notifications);
  
  /// @deprecated Usar stateStream en su lugar
  Stream<int> get unreadCountStream => 
      _stateController.stream.map((s) => s.unreadCount);
  
  /// @deprecated Usar stateStream.notifications en su lugar
  List<AppNotification> get notifications => _state.notifications;
  
  /// @deprecated Usar stateStream.unreadCount en su lugar
  int get unreadCount => _state.unreadCount;
  
  /// @deprecated Usar stateStream.unreadAlertCount en su lugar
  int get unreadAlertCount => _state.unreadAlertCount;
  
  /// @deprecated Usar stateStream.unreadMlCount en su lugar  
  int get unreadMlCount => _state.unreadMlCount;
  
  /// @deprecated Usar stateStream.unreadAlerts en su lugar
  List<AppNotification> get unreadAlerts => _state.unreadAlerts;
  
  /// @deprecated Usar stateStream.unreadMlEvents en su lugar
  List<AppNotification> get unreadMlEvents => _state.unreadMlEvents;
  
  /// @deprecated Ya no se usa cache
  void invalidateCache() {
    _log('invalidateCache() called - no-op, cache removed');
  }

  // ═══════════════════════════════════════════════════════════════════
  // OPERACIONES - Todas async, todas emiten nuevo estado
  // ═══════════════════════════════════════════════════════════════════

  /// Carga notificaciones desde el servidor.
  /// 
  /// SIEMPRE consulta la API (sin cache).
  /// Si ya hay un fetch en progreso, espera a que termine.
  Future<void> fetchNotifications({bool force = false}) async {
    _log('fetchNotifications(force: $force) called');
    
    // Si ya hay un fetch en progreso, esperar a que termine
    if (_fetchCompleter != null && !_fetchCompleter!.isCompleted) {
      _log('fetch already in progress, waiting...');
      await _fetchCompleter!.future;
      return;
    }
    
    _fetchCompleter = Completer<void>();
    
    // Emitir estado de carga
    _emit(_state.copyWith(isLoading: true, clearError: true));
    
    try {
      _log('fetching from API...');
      // FIX FREEZE: Timeout para evitar que la UI se congele
      final data = await _api.getList('/notifications/unread?limit=$_maxNotifications')
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Notificaciones tardaron demasiado en cargar');
      });
      
      var notifications = data
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      
      // Ordenar por prioridad (alertas primero, luego por fecha)
      notifications.sort((a, b) {
        final priorityCompare = a.priority.compareTo(b.priority);
        if (priorityCompare != 0) return priorityCompare;
        return b.createdAt.compareTo(a.createdAt);
      });
      
      _log('fetched ${notifications.length} notifications, ${notifications.where((n) => !n.isRead).length} unread');
      
      // Emitir nuevo estado
      _emit(NotificationState(
        notifications: notifications,
        isLoading: false,
        lastFetchTime: DateTime.now(),
      ));
      
    } catch (e) {
      _log('fetch error: $e');
      _emit(_state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    } finally {
      _fetchCompleter?.complete();
    }
  }

  /// Marca una notificación como leída.
  /// 
  /// FIX AUDITORIA: Flujo determinista para evitar inconsistencias:
  /// 1. Actualizar estado local INMEDIATAMENTE (UI responsiva)
  /// 2. Persistir en DB (SSOT)
  /// 3. NO hacer fetch inmediato (evita race conditions)
  /// 4. El polling periódico sincronizará eventualmente
  /// 
  /// Esto evita:
  /// - Contador que no baja (porque el fetch trae datos viejos)
  /// - Notificaciones que reaparecen (race condition)
  /// - UI lenta (esperar fetch)
  Future<void> markAsRead(String notificationId) async {
    _log('markAsRead($notificationId) called');
    
    // 1. Actualizar estado local INMEDIATAMENTE
    // Remover la notificación de la lista (ya no es "unread")
    final updatedNotifications = _state.notifications
        .where((n) => n.id != notificationId)
        .toList();
    
    _emit(_state.copyWith(notifications: updatedNotifications));
    _log('local state updated: removed notification, new count=${updatedNotifications.length}');
    
    try {
      // 2. Persistir en DB (SSOT)
      await _api.postJson('/notifications/mark-read', {'ids': [notificationId]});
      _log('markAsRead API call successful');
      
      // 3. NO hacer fetch inmediato - el polling sincronizará
      // Esto evita race conditions donde el servidor aún no ha procesado el UPDATE
      
    } catch (e) {
      _log('markAsRead error: $e');
      // En caso de error, restaurar estado desde servidor
      await fetchNotifications(force: true);
    }
  }

  /// Marca múltiples notificaciones como leídas.
  /// 
  /// FIX AUDITORIA: Mismo patrón que markAsRead - actualizar local primero,
  /// persistir en DB, NO fetch inmediato.
  Future<void> markMultipleAsRead(List<String> ids) async {
    if (ids.isEmpty) return;
    _log('markMultipleAsRead(${ids.length} ids) called');
    
    // 1. Actualizar estado local INMEDIATAMENTE
    final idsSet = ids.toSet();
    final updatedNotifications = _state.notifications
        .where((n) => !idsSet.contains(n.id))
        .toList();
    
    _emit(_state.copyWith(notifications: updatedNotifications));
    _log('local state updated: removed ${ids.length} notifications, new count=${updatedNotifications.length}');
    
    try {
      // 2. Persistir en DB (SSOT)
      await _api.postJson('/notifications/mark-read', {'ids': ids});
      _log('markMultipleAsRead API call successful');
      
      // 3. NO fetch inmediato - el polling sincronizará
      
    } catch (e) {
      _log('markMultipleAsRead error: $e');
      // En caso de error, restaurar estado desde servidor
      await fetchNotifications(force: true);
    }
  }

  /// Marca todas como leídas
  Future<void> markAllAsRead() async {
    final unreadIds = _state.notifications
        .where((n) => !n.isRead)
        .map((n) => n.id)
        .toList();
    
    if (unreadIds.isEmpty) {
      _log('markAllAsRead: no unread notifications');
      return;
    }
    
    _log('markAllAsRead: ${unreadIds.length} notifications');
    await markMultipleAsRead(unreadIds);
  }

  /// Obtiene notificaciones filtradas por tipo
  List<AppNotification> getBySource(NotificationSource source) {
    return _state.notifications.where((n) => n.source == source).toList();
  }

  /// Verifica si hay alertas activas
  bool get hasActiveAlerts => _state.unreadAlertCount > 0;

  // ═══════════════════════════════════════════════════════════════════
  // INTERNOS
  // ═══════════════════════════════════════════════════════════════════

  /// Emite nuevo estado y notifica a todos los listeners
  void _emit(NotificationState newState) {
    _state = newState;
    _stateController.add(newState);
    _log('state emitted: ${newState.unreadCount} unread, loading=${newState.isLoading}');
  }

  /// Log con timestamp para debugging
  void _log(String message) {
    if (_enableLogs) {
      final ts = DateTime.now().toIso8601String().substring(11, 23);
      debugPrint('[NotificationService $ts] $message');
    }
  }

  /// Limpia recursos
  void dispose() {
    stopPolling();
    _debounceTimer?.cancel();
    _realtimeStateSubscription?.cancel();
    _stateController.close();
  }

  // ═══════════════════════════════════════════════════════════════════
  // POLLING CENTRALIZADO (BUG-2 FIX)
  // ═══════════════════════════════════════════════════════════════════

  /// Inicia polling de notificaciones (solo si no está activo)
  void startPolling() {
    if (_pollTimer != null && _pollTimer!.isActive) {
      _log('Polling already active, skipping');
      return;
    }
    
    _log('Polling started');
    // Fetch inicial inmediato
    fetchNotifications();
    
    // Timer periódico
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (_stateController.isClosed) {
        _log('Stream closed, stopping polling');
        stopPolling();
        return;
      }
      fetchNotifications();
    });
  }

  /// Detiene polling de notificaciones
  void stopPolling() {
    if (_pollTimer != null) {
      _log('Polling stopped');
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  /// Verifica si polling está activo
  bool get isPolling => _pollTimer != null && _pollTimer!.isActive;
}
