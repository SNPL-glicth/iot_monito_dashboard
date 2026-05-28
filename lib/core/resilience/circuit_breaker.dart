import 'dart:async';

import 'circuit_breaker_config.dart';

enum CircuitState { closed, open, halfOpen }

class CircuitOpenException implements Exception {
  final String message;
  CircuitOpenException(this.message);
}

class CircuitBreaker<T> {
  CircuitBreaker(this._config) : _currentOpenDurationMs = _config.openDurationMs;

  final CircuitBreakerConfig _config;
  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  int _successCount = 0;
  int _currentOpenDurationMs;
  DateTime? _openedAt;

  final _stateController = StreamController<CircuitState>.broadcast();

  CircuitState get state => _state;
  Stream<CircuitState> get stateStream => _stateController.stream;

  Future<T> execute(Future<T> Function() operation) async {
    if (_state == CircuitState.open) {
      if (_openedAt != null &&
          DateTime.now().difference(_openedAt!).inMilliseconds >= _currentOpenDurationMs) {
        _transitionTo(CircuitState.halfOpen);
      } else {
        throw CircuitOpenException('Circuit breaker is open');
      }
    }

    try {
      final result = await operation();
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
    }
  }

  void _onSuccess() {
    if (_state == CircuitState.halfOpen) {
      _successCount++;
      if (_successCount >= _config.successThreshold) {
        _reset();
      }
    } else {
      _failureCount = 0;
    }
  }

  void _onFailure() {
    _failureCount++;
    if (_state == CircuitState.halfOpen) {
      _open();
    } else if (_failureCount >= _config.failureThreshold) {
      _open();
    }
  }

  void _open() {
    _state = CircuitState.open;
    _openedAt = DateTime.now();
    _successCount = 0;
    _currentOpenDurationMs = (_currentOpenDurationMs * _config.backoffFactor).round();
    if (_currentOpenDurationMs > _config.maxOpenDurationMs) {
      _currentOpenDurationMs = _config.maxOpenDurationMs;
    }
    _stateController.add(_state);
  }

  void _reset() {
    _state = CircuitState.closed;
    _failureCount = 0;
    _successCount = 0;
    _currentOpenDurationMs = _config.openDurationMs;
    _openedAt = null;
    _stateController.add(_state);
  }

  void _transitionTo(CircuitState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  void dispose() {
    _stateController.close();
  }
}
