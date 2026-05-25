import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/auth_storage.dart';
import '../auth/token_manager.dart';
import 'api_client.dart';

/// Evento emitido cuando el interceptor detecta un error 401/403.
class UnauthorizedEvent {
  const UnauthorizedEvent({required this.message});
  final String message;
}

/// Interceptor global de errores de red.
///
/// Responsabilidades:
/// - 401/403 → limpiar sesión y emitir [UnauthorizedEvent] para redirigir a login.
/// - 500/timeout → mostrar [MaterialBanner] no intrusivo con opción de reintentar.
/// - No interrumpe la navegación actual salvo en 401.
class ApiErrorInterceptor {
  static final ApiErrorInterceptor _instance = ApiErrorInterceptor._internal();
  factory ApiErrorInterceptor() => _instance;
  ApiErrorInterceptor._internal();

  final _unauthorizedController = StreamController<UnauthorizedEvent>.broadcast();

  /// Stream al que [AppBootstrapper] debe suscribirse para redirigir a login.
  Stream<UnauthorizedEvent> get onUnauthorized => _unauthorizedController.stream;

  GlobalKey<ScaffoldMessengerState>? _scaffoldMessengerKey;

  /// Debe llamarse desde [main.dart] después de crear el MaterialApp key.
  void attachScaffoldMessengerKey(GlobalKey<ScaffoldMessengerState> key) {
    _scaffoldMessengerKey = key;
  }

  /// Procesa cualquier excepción proveniente de [ApiClient].
  void handle(dynamic error) {
    if (error is ApiException) {
      _handleApiException(error);
    } else if (error is ApiTimeoutException) {
      _showNetworkBanner(
        title: 'Conexión lenta',
        message: error.toString(),
        isRetryable: true,
      );
    }
  }

  void _handleApiException(ApiException e) {
    if (e.statusCode == 401 || e.statusCode == 403) {
      _performLogout(e.statusCode == 401
          ? 'Tu sesión expiró. Por favor inicia sesión de nuevo.'
          : 'No tienes permisos para esta acción.');
    } else if (e.statusCode >= 500) {
      _showNetworkBanner(
        title: 'Error del servidor',
        message: 'El servidor respondió con error ${e.statusCode}. Intenta más tarde.',
        isRetryable: true,
      );
    }
  }

  void _performLogout(String message) async {
    try {
      await AuthStorage().clearSession();
    } catch (_) {
      // Ignorar errores de limpieza
    }
    ApiClient.authToken = null;
    TokenManager().stopMonitoring();

    if (!_unauthorizedController.isClosed) {
      _unauthorizedController.add(UnauthorizedEvent(message: message));
    }
  }

  void _showNetworkBanner({
    required String title,
    required String message,
    required bool isRetryable,
  }) {
    final messenger = _scaffoldMessengerKey?.currentState;
    if (messenger == null) return;

    // Remover banner anterior para evitar acumulación
    messenger.clearMaterialBanners();

    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: const Color(0xFF7F1D1D),
        content: Text(
          '$title: $message',
          style: const TextStyle(color: Colors.white),
        ),
        leading: const Icon(Icons.wifi_off, color: Colors.white),
        actions: [
          if (isRetryable)
            TextButton(
              onPressed: () {
                messenger.hideCurrentMaterialBanner();
                // Los widgets pueden suscribirse a un stream de "retry" si lo necesitan,
                // pero por ahora el banner solo se oculta y el usuario reintenta manualmente.
              },
              child: const Text('REINTENTAR', style: TextStyle(color: Colors.white)),
            ),
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text('IGNORAR', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void dispose() {
    _unauthorizedController.close();
  }
}
