import 'dart:async';
import 'dart:convert';

import '../network/api_client.dart';
import '../realtime/realtime_service.dart';
import 'auth_storage.dart';

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
  final AuthStorage _storage = AuthStorage();
  
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
  
  /// Realiza el refresh del token usando /auth/refresh-token (Bearer flow)
  Future<void> _performRefresh() async {
    try {
      final currentToken = ApiClient.authToken;
      final currentRefreshToken = _refreshToken;
      
      if (currentToken == null || currentToken.isEmpty) {
        return;
      }
      
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        // Sin refresh token, no podemos refrescar
        return;
      }
      
      final apiClient = ApiClient();
      // FIX AUTH: Usar nuevo endpoint /auth/refresh-token con refresh_token en body
      final response = await apiClient.postJsonAndDecode('/auth/refresh-token', {
        'refresh_token': currentRefreshToken,
      });
      
      final ok = response['ok'] as bool? ?? false;
      if (!ok) {
        // Refresh falló, reintentar más tarde
        _refreshTimer = Timer(const Duration(minutes: 5), _performRefresh);
        return;
      }
      
      final newToken = response['access_token'] as String?;
      final newRefreshToken = response['refresh_token'] as String?;
      
      if (newToken != null && newToken.isNotEmpty) {
        // Actualizar tokens en memoria
        ApiClient.authToken = newToken;
        _refreshToken = newRefreshToken;
        
        // Actualizar tokens en storage
        final session = await _storage.loadSession();
        if (session != null) {
          await _storage.saveSession(
            token: newToken,
            role: session.role,
            username: session.username,
            refreshToken: newRefreshToken,
          );
        }
        
        // Reprogramar siguiente refresh
        startMonitoring(newToken);
      }
    } catch (e) {
      // Si falla, reintentar en 5 minutos
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
