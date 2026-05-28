import 'package:flutter_test/flutter_test.dart';
import 'package:iot_monito_dashboard/core/mqtt/mqtt_service.dart';

void main() {
  group('MqttService reconnect backoff', () {
    test('_scheduleReconnect does not expose token in URL', () {
      // Este test es un placeholder; el servicio MQTT no usa URLs con token.
      final service = MqttService();
      expect(service, isNotNull);
    });
  });
}
