import 'package:flutter_test/flutter_test.dart';
import 'package:iot_monito_dashboard/core/realtime/realtime_service.dart';

void main() {
  group('RealtimeService URL Security', () {
    test('buildWebSocketUrl never exposes token in query string', () {
      final service = RealtimeService();
      final url = service.buildWebSocketUrl();

      expect(url, isNot(contains('?token=')),
          reason: 'JWT must not appear as query parameter');
      expect(url, isNot(contains('&token=')),
          reason: 'JWT must not appear anywhere in the URL');
    });

    test('buildWebSocketUrl generates correct ws/wss scheme', () {
      final service = RealtimeService();
      final url = service.buildWebSocketUrl();

      expect(
        url.startsWith('ws://') || url.startsWith('wss://'),
        isTrue,
        reason: 'WebSocket URL should start with ws:// or wss://',
      );
    });

    test('buildWebSocketUrl ends with /realtime path', () {
      final service = RealtimeService();
      final url = service.buildWebSocketUrl();

      expect(url.endsWith('/realtime'), isTrue,
          reason: 'URL must target the /realtime namespace');
    });
  });
}
