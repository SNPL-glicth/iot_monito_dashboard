/// Modelos y tipos compartidos del servicio WebSocket.
library;

/// Tipos de eventos que el servidor puede enviar
enum RealtimeEventType {
  readingsLatest,
  alertsActive,
  predictionsLatest,
  mlEventsActive,
  sensorsConsolidated,
}

/// Evento recibido del servidor
class RealtimeEvent {
  const RealtimeEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  final RealtimeEventType type;
  final dynamic data;
  final DateTime timestamp;
}

/// Callback para eventos de realtime
typedef RealtimeEventCallback = void Function(RealtimeEvent event);

/// Estado de la conexión WebSocket
enum RealtimeConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}
