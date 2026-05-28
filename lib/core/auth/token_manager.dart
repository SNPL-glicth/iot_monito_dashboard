import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../realtime/realtime_service.dart';
import 'storage/auth_storage_interface.dart';
import 'storage/secure_token_storage.dart';

/// Gestiona el ciclo de vida del token JWT con refresh automático.
/// 
/// Características:
/// - Decodifica el token para obtener tiempo de expiración
/// - Programa refresh automático 5 minutos antes de expirar
/// - Usa /auth/refresh-token con refresh_token en body (NO cookies)
/// - Reintenta refresh si falla
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  Timer? _refreshTimer;
  final IAuthStorage _storage = SecureTokenStorage(
    storage: const FlutterSecureStorage(),
  );

  /// Refresh token almacenado en memoria (también persistido en storage)
  String? _refreshToken;
  
  /// FIX CRÍTICO: Tiempo antes de expiración para hacer refresh (5 minutos = 300 segundos)
  static const int _refreshBeforeExpirySecs = 5 * 60;
  
  /// Guarda el refresh token para usar en refresh automático
  void setRefreshToken(String? token) {
    _refreshToken = token;
  }
  
  /// Obtiene el refresh token actual
  String? get refreshToken => _refreshToken;
  
  /// Inicia el monitoreo del token actual
  void startMonitoring(String token) {
    _cancelTimer();
    
    final expiresAt = _getTokenExpiry(token);
    if (expiresAt == null) {
      // Token sin expiración o inválido, no programar refresh
      return;
    }
    
    final now = DateTime.now();
    final refreshAt = expiresAt.subtract(Duration(seconds: _refreshBeforeExpirySecs));
    
    if (refreshAt.isBefore(now)) {
      // FIX FREEZE: Diferir refresh para no bloquear el inicio
      // Si el token ya está próximo a expirar, esperar 5 segundos antes de refrescar
      _refreshTimer = Timer(const Duration(seconds: 5), _performRefresh);
    } else {
      // Programar refresh
      final delay = refreshAt.difference(now);
      _refreshTimer = Timer(delay, _performRefresh);
    }
  }
  
  /// Detiene el monitoreo y desconecta WebSocket
  void stopMonitoring() {
    _cancelTimer();
    RealtimeService().disconnect();
  }
  
  void _cancelTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  /// Extrae la fecha de expiración del token JWT
  DateTime? _getTokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      // Decodificar payload (parte 2)
      String payload = parts[1];
      // Agregar padding si es necesario
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      
      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> json = jsonDecode(decoded);
      
      final exp = json['exp'];
      if (exp == null) return null;
      
      // exp es timestamp en segundos
      return DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    } catch (e) {
      return null;
    }
  }
  
  /// Realiza el refresh del token de forma sincrónica y retorna true si tuvo éxito.
  /// Útil para el AppBootstrapper que debe validar la sesión antes de enrutar.
  Future<bool> refreshTokenNow() async {
    try {
      final currentToken = ApiClient.authToken;
      final currentRefreshToken = _refreshToken;

      if (currentToken == null || currentToken.isEmpty) {
        return false;
      }

      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        return false;
      }

      final apiClient = ApiClient();
      final response = await apiClient.postJsonAndDecode('/auth/refresh-token', {
        'refresh_token': currentRefreshToken,
      });

      final ok = response['ok'] as bool? ?? false;
      if (!ok) {
        return false;
      }

      final newToken = response['access_token'] as String?;
      final newRefreshToken = response['refresh_token'] as String?;

      if (newToken != null && newToken.isNotEmpty) {
        ApiClient.authToken = newToken;
        _refreshToken = newRefreshToken;

        await _storage.saveAccessToken(newToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await _storage.saveRefreshToken(newRefreshToken);
        }

        startMonitoring(newToken);
        // FIX SEGURIDAD: Reautenticar WebSocket sin reconectar
        RealtimeService().reauthenticate(newToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Realiza el refresh del token usando /auth/refresh-token (Bearer flow)
  Future<void> _performRefresh() async {
    final success = await refreshTokenNow();
    if (!success) {
      _refreshTimer = Timer(const Duration(minutes: 5), _performRefresh);
    }
  }
  
  /// Verifica si el token actual está próximo a expirar (menos de 5 minutos)
  bool isTokenExpiringSoon(String token) {
    final expiresAt = _getTokenExpiry(token);
    if (expiresAt == null) return false;
    
    final now = DateTime.now();
    final refreshAt = expiresAt.subtract(Duration(seconds: _refreshBeforeExpirySecs));
    
    return now.isAfter(refreshAt);
  }
  
  /// Verifica si el token ya expiró
  bool isTokenExpired(String token) {
    final expiresAt = _getTokenExpiry(token);
    if (expiresAt == null) return false;
    
    return DateTime.now().isAfter(expiresAt);
  }
  
  /// Tiempo restante hasta expiración (para mostrar en UI si se desea)
  Duration? getTimeUntilExpiry(String token) {
    final expiresAt = _getTokenExpiry(token);
    if (expiresAt == null) return null;
    
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
