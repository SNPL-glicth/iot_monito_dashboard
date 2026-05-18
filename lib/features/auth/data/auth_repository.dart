import '../../../core/auth/auth_storage.dart';
import '../../../core/auth/current_user.dart';
import '../../../core/auth/token_manager.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/network/api_client.dart';

//la cclase que define
class LoginResult {
  LoginResult({
    required this.token,
    required this.role,
  });

  final String token;
  final UserRole role;
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

// SINGLETON: Evita crear múltiples instancias que causan memory leaks
class AuthRepository {
  // Singleton instance
  static final AuthRepository _instance = AuthRepository._internal();
  
  // Factory constructor retorna siempre la misma instancia
  factory AuthRepository({ApiClient? apiClient}) => _instance;
  
  // Constructor privado interno
  AuthRepository._internal() : _apiClient = ApiClient();

  final ApiClient _apiClient;
  final AuthStorage _authStorage = AuthStorage();

  /// Llama al backend NestJS para autenticar al usuario.
  ///
  /// Para Flutter usamos el login "legacy" que devuelve access_token (Bearer),
  /// porque el endpoint /auth/login está pensado para web con cookies HttpOnly.
  ///
  /// POST /auth/login-token
  /// Body: { "username": "...", "password": "..." }
  /// Respuesta: { access_token, role, user }
  Future<LoginResult> login(String username, String password) async {
    final path = '/auth/login-token';

    Map<String, dynamic> response;
    try {
      response = await _apiClient.postJsonAndDecode(path, {
        'username': username,
        'password': password,
      });
    } on ApiException catch (e) {
      // Mensajes amigables para el login
      if (e.statusCode == 401) {
        throw AuthException('Usuario o contraseña incorrectos.');
      }
      if (e.statusCode == 403) {
        throw AuthException('Acceso denegado.');
      }
      if (e.statusCode >= 500) {
        throw AuthException('Servidor no disponible. Intenta más tarde.');
      }
      throw AuthException('Error al iniciar sesión (${e.statusCode}).');
    } catch (_) {
      throw AuthException('No se pudo iniciar sesión. Revisa tu conexión.');
    }

    final token = response['access_token'] as String?;
    final refreshToken = response['refresh_token'] as String?;
    
    // guardar token global para que ApiClient lo use en todas las peticiones
    ApiClient.authToken = token;

    final userRaw = (response['user'] as Map?)?.cast<String, dynamic>();
    if (userRaw != null) {
      CurrentUser.value = CurrentUser.fromJson(userRaw);
    }

    final roleStr = (response['role'] ?? userRaw?['role'])?.toString();

    if (token == null || roleStr == null) {
      throw Exception('Respuesta de login inválida');
    }

    // FIX AUTH: Guardar refresh_token para poder refrescar sesión
    TokenManager().setRefreshToken(refreshToken);
    
    // FIX AUTH: Iniciar monitoreo de token para refresh automático
    TokenManager().startMonitoring(token);

    final role = _mapRole(roleStr);

    // FIX 2: Persistir sesión en storage
    await _authStorage.saveSession(
      token: token,
      role: roleStr,
      username: userRaw?['username']?.toString(),
      refreshToken: refreshToken,
    );

    return LoginResult(token: token, role: role);
  }

  UserRole _mapRole(String raw) {
    switch (raw.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'operator':
        return UserRole.operator;
      case 'viewer':
      default:
        return UserRole.viewer;
    }
  }
}