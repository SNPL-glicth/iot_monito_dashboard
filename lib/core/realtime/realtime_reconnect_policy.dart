/// Política de reconexión con backoff exponencial y jitter para WebSocket.
///
/// Extraído de [RealtimeService] para mantener el archivo principal < 180 líneas.
library;

import 'dart:math';

import 'package:flutter/foundation.dart' show debugPrint;

/// Calcula el delay de reconexión con backoff exponencial + jitter.
///
/// Fórmula: baseMs * 2^attempt + random(0, 1000ms)
/// Cap máximo: 60 segundos.
class RealtimeReconnectPolicy {
  const RealtimeReconnectPolicy({
    this.baseDelay = const Duration(seconds: 5),
    this.maxAttempts = 5,
    this.cap = const Duration(seconds: 60),
    this.jitterMaxMs = 1000,
  });

  final Duration baseDelay;
  final int maxAttempts;
  final Duration cap;
  final int jitterMaxMs;

  /// Retorna el delay calculado o `null` si se excedieron los intentos.
  Duration? computeDelay(int attempt) {
    if (attempt >= maxAttempts) return null;

    final baseMs = baseDelay.inMilliseconds;
    final exponentialMs = baseMs * (1 << attempt);
    final capMs = cap.inMilliseconds;
    final cappedMs = exponentialMs > capMs ? capMs : exponentialMs;
    final jitterMs = Random().nextInt(jitterMaxMs);
    return Duration(milliseconds: cappedMs + jitterMs);
  }

  /// Logs del intento de reconexión.
  void logSchedule(int attempt, Duration delay) {
    debugPrint(
      '[RealtimeReconnectPolicy] Reconnecting in '
      '${delay.inSeconds}s.${delay.inMilliseconds % 1000}ms '
      '(attempt ${attempt + 1}/$maxAttempts)',
    );
  }
}
