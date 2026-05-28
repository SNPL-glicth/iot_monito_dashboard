/// Política de reconexión con backoff exponencial y jitter para MQTT.
///
/// Extraído de [MqttService] para mantener el archivo principal < 180 líneas.
library;

import 'dart:math';

import 'package:flutter/foundation.dart' show debugPrint;

/// Calcula el delay de reconexión con backoff exponencial + jitter.
///
/// Fórmula: baseMs * 2^attempt + random(0, 500ms)
/// Cap máximo: 60 segundos.
class MqttReconnectPolicy {
  const MqttReconnectPolicy({
    this.baseDelaySeconds = 5,
    this.maxAttempts = 5,
    this.capSeconds = 60,
    this.jitterMaxMs = 500,
  });

  final int baseDelaySeconds;
  final int maxAttempts;
  final int capSeconds;
  final int jitterMaxMs;

  /// Retorna el delay calculado o `null` si se excedieron los intentos.
  Duration? computeDelay(int attempt) {
    if (attempt >= maxAttempts) return null;

    final baseMs = baseDelaySeconds * 1000;
    final exponentialMs = baseMs * (1 << attempt);
    final capMs = capSeconds * 1000;
    final cappedMs = exponentialMs > capMs ? capMs : exponentialMs;
    final jitterMs = Random().nextInt(jitterMaxMs);
    return Duration(milliseconds: cappedMs + jitterMs);
  }

  void logSchedule(int attempt, Duration delay) {
    debugPrint(
      '[MqttReconnectPolicy] Reconnecting in '
      '${delay.inSeconds}s.${delay.inMilliseconds % 1000}ms '
      '(attempt ${attempt + 1}/$maxAttempts)',
    );
  }
}
