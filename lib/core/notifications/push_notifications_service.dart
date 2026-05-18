import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';

/// Servicio centralizado para manejar notificaciones push (FCM)
/// y registrar el token del dispositivo en el backend Nest.
class PushNotificationsService {
  PushNotificationsService._();

  static final PushNotificationsService instance = PushNotificationsService._();

  final _messaging = FirebaseMessaging.instance;
  final _storage = const FlutterSecureStorage();

  static const _kFcmTokenKey = 'fcm_token';
  
  // FIX FREEZE: Flag para evitar múltiples inicializaciones
  bool _initialized = false;
  bool _initializing = false;

  /// Debe llamarse al inicio de la app (por ejemplo en main.dart)
  /// después de inicializar Firebase.
  Future<void> init({required BuildContext context}) async {
    // FIX FREEZE: Evitar re-inicialización múltiple
    if (_initialized || _initializing) return;
    _initializing = true;
    
    try {
      // Pedir permisos (sobre todo iOS)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('FCM permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      // Obtener / refrescar token
      final token = await _messaging.getToken();
      if (token != null) {
        await _onNewToken(token);
      }

      // En versiones recientes de firebase_messaging, onTokenRefresh es
      // una propiedad de instancia, no estática.
      _messaging.onTokenRefresh.listen(_onNewToken);

      // Manejo básico de mensajes en foreground (opcional)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Push recibida en foreground: ${message.messageId}');
      });
      
      _initialized = true;
    } catch (e) {
      debugPrint('PushNotificationsService.init() error: $e');
    } finally {
      _initializing = false;
    }
  }

  Future<void> _onNewToken(String token) async {
    final last = await _storage.read(key: _kFcmTokenKey);
    if (last == token) {
      // Ya registrado, evitamos golpear backend innecesariamente.
      return;
    }

    await _storage.write(key: _kFcmTokenKey, value: token);

    try {
      final client = ApiClient();
      // Ajusta la plataforma según el build si lo necesitas.
      const platform = 'android';

      await client.postJsonAndDecode('/notifications/register-device', {
        'fcmToken': token,
        'platform': platform,
      });
    } catch (e) {
      debugPrint('Error registrando FCM token en backend: $e');
    }
  }
}
