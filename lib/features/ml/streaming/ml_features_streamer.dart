import 'dart:async';

import 'ml_stream_config.dart';

abstract class IMlFeaturesRepository {
  Future<dynamic> fetchFeatures(int sensorId);
}

class MlFeaturesStreamer {
  MlFeaturesStreamer(this._repository, this._config)
      : _currentIntervalMs = _config.initialIntervalMs;

  final IMlFeaturesRepository _repository;
  final MlStreamConfig _config;

  StreamController<dynamic>? _controller;
  Timer? _timer;
  int _currentIntervalMs;
  int _consecutiveErrors = 0;

  Stream<dynamic> stream(int sensorId) {
    _controller = StreamController<dynamic>(
      onCancel: dispose,
    );
    _scheduleFetch(sensorId);
    return _controller!.stream;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }

  void _scheduleFetch(int sensorId) {
    _timer = Timer(Duration(milliseconds: _currentIntervalMs), () async {
      await _fetchAndEmit(sensorId);
    });
  }

  Future<void> _fetchAndEmit(int sensorId) async {
    if (_controller == null || _controller!.isClosed) return;

    try {
      final features = await _repository.fetchFeatures(sensorId);
      _controller!.add(features);
      _resetBackoff();
    } catch (e) {
      _consecutiveErrors++;
      _applyBackoff();

      if (_consecutiveErrors >= _config.maxConsecutiveErrors) {
        _controller!.addError(e);
        dispose();
        return;
      }
    }

    _scheduleFetch(sensorId);
  }

  void _resetBackoff() {
    _consecutiveErrors = 0;
    _currentIntervalMs = _config.initialIntervalMs;
  }

  void _applyBackoff() {
    _currentIntervalMs = (
      _currentIntervalMs * _config.backoffFactor
    ).round();
    if (_currentIntervalMs > _config.maxIntervalMs) {
      _currentIntervalMs = _config.maxIntervalMs;
    }
  }
}
