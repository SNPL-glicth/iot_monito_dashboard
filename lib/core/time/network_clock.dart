import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Reloj que intenta obtener la hora real por internet para Colombia (America/Bogota)
/// y cae a una aproximación local si falla.
class NetworkClock {
  static const Duration _fallbackBogotaOffset = Duration(hours: -5);
  static const Duration _timeout = Duration(seconds: 5);

  static Uri get _bogotaEndpoint => Uri.parse(
        'https://worldtimeapi.org/api/timezone/America/Bogota',
      );

  /// Devuelve la hora actual en Colombia (Bogotá).
  ///
  /// - Primero intenta por internet.
  /// - Si falla (sin conexión, timeout, etc.), usa DateTime.now() aproximado a UTC-5.
  static Future<DateTime> nowBogota() async {
    try {
      final res = await http.get(_bogotaEndpoint).timeout(_timeout);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          final unixtime = (decoded['unixtime'] as num?)?.toInt();
          final rawOffset = (decoded['raw_offset'] as num?)?.toInt();
          final dstOffset = (decoded['dst_offset'] as num?)?.toInt() ?? 0;

          if (unixtime != null && rawOffset != null) {
            final utc = DateTime.fromMillisecondsSinceEpoch(unixtime * 1000, isUtc: true);
            return utc.add(Duration(seconds: rawOffset + dstOffset));
          }

          final datetimeStr = decoded['datetime']?.toString();
          if (datetimeStr != null && datetimeStr.isNotEmpty) {
            final parsed = DateTime.tryParse(datetimeStr);
            if (parsed != null) {
              // Si viene con offset, Dart lo normaliza a UTC (isUtc=true). Convertimos a Bogota.
              return parsed.isUtc ? parsed.add(_fallbackBogotaOffset) : parsed;
            }
          }
        }
      }
    } catch (_) {
      // fallback abajo
    }

    return DateTime.now().toUtc().add(_fallbackBogotaOffset);
  }

  /// Convierte una fecha/hora UTC a hora Colombia (UTC-5).
  static DateTime utcToBogota(DateTime utc) => utc.toUtc().add(_fallbackBogotaOffset);
}
