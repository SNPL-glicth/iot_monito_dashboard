import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iot_monito_dashboard/features/ml/streaming/ml_stream_config.dart';
import 'package:iot_monito_dashboard/features/ml/streaming/ml_features_streamer.dart';

class MockRepository implements IMlFeaturesRepository {
  int callCount = 0;
  bool shouldFail = false;

  @override
  Future<dynamic> fetchFeatures(int sensorId) async {
    callCount++;
    if (shouldFail) throw Exception('network error');
    return {'sensorId': sensorId};
  }
}

void main() {
  group('MlFeaturesStreamer', () {
    late MockRepository repo;
    late MlFeaturesStreamer streamer;

    setUp(() {
      repo = MockRepository();
      streamer = MlFeaturesStreamer(
        repo,
        const MlStreamConfig(
          initialIntervalMs: 100,
          maxIntervalMs: 1000,
          backoffFactor: 2.0,
          maxConsecutiveErrors: 3,
        ),
      );
    });

    tearDown(() {
      streamer.dispose();
    });

    test('stream emits features on success', () async {
      final events = <dynamic>[];
      final sub = streamer.stream(1).listen(events.add);
      await Future.delayed(const Duration(milliseconds: 250));
      await sub.cancel();
      expect(events.length, greaterThanOrEqualTo(1));
    });

    test('stream applies backoff on consecutive errors', () async {
      repo.shouldFail = true;
      final sub = streamer.stream(1).listen(null);
      await Future.delayed(const Duration(milliseconds: 500));
      await sub.cancel();
      expect(repo.callCount, greaterThanOrEqualTo(2));
    });

    test('dispose cancels timer without error', () {
      streamer.stream(1);
      streamer.dispose();
      expect(true, isTrue);
    });
  });
}
