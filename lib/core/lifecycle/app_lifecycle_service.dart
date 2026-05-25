import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Servicio centralizado de lifecycle de la aplicación.
///
/// Implementa un único [WidgetsBindingObserver] y notifica a todos los
/// suscriptores mediante callbacks o streams. Los widgets con polling
/// deben suscribirse aquí en lugar de implementar su propio observer.
class AppLifecycleService extends WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  final _pauseController = StreamController<void>.broadcast();
  final _resumeController = StreamController<void>.broadcast();

  /// Stream que emite cuando la app entra en pausa/inactive/hidden.
  Stream<void> get onAppPaused => _pauseController.stream;

  /// Stream que emite cuando la app vuelve a primer plano (resumed).
  Stream<void> get onAppResumed => _resumeController.stream;

  bool _isAppActive = true;

  /// Estado actual de la app. `true` cuando está en primer plano.
  bool get isAppActive => _isAppActive;

  /// Registra este observer en [WidgetsBinding]. Llámalo una sola vez,
  /// preferiblemente desde [main.dart] o [AppBootstrapper].
  void attach() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Remueve el observer. Llámalo al destruir el root widget.
  void detach() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (_isAppActive) {
          _isAppActive = false;
          if (kDebugMode) {
            debugPrint('[AppLifecycleService] app PAUSED ($state)');
          }
          if (!_pauseController.isClosed) {
            _pauseController.add(null);
          }
        }
        break;
      case AppLifecycleState.resumed:
        if (!_isAppActive) {
          _isAppActive = true;
          if (kDebugMode) {
            debugPrint('[AppLifecycleService] app RESUMED');
          }
          if (!_resumeController.isClosed) {
            _resumeController.add(null);
          }
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void dispose() {
    detach();
    _pauseController.close();
    _resumeController.close();
  }
}
