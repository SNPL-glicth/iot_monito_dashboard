import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'current_user.dart';

/// Maneja la persistencia opcional de sesión ("mantener sesión iniciada").
///
/// Guarda el token JWT y algunos metadatos mínimos del usuario para poder
/// reconstruir el contexto al abrir la app sin volver a loguear.
class StoredSession {
  const StoredSession({
    required this.token,
    required this.role,
    this.username,
    this.refreshToken,
  });

  final String token;
  final String role;
  final String? username;
  final String? refreshToken;
}

/// FIX PERFORMANCE: AuthStorage optimizado para evitar bloqueo del main thread.
/// 
/// En debug/emulador, FlutterSecureStorage es extremadamente lento (1-3s por operación)
/// debido a la verificación de bytecode. Usamos SharedPreferences como fallback rápido
/// en debug, y SecureStorage solo en release para datos sensibles.
class AuthStorage {
  AuthStorage({FlutterSecureStorage? storage})
      : _secureStorage = storage ?? const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyRole = 'auth_role';
  static const _keyUsername = 'auth_username';
  static const _keyRefreshToken = 'auth_refresh_token';

  final FlutterSecureStorage _secureStorage;
  
  /// En debug usamos SharedPreferences (rápido) para no bloquear UI.
  /// En release usamos SecureStorage (seguro) para protección real.
  bool get _useSecureStorage => kReleaseMode;

  Future<void> saveSession({
    required String token,
    required String role,
    String? username,
    String? refreshToken,
  }) async {
    if (_useSecureStorage) {
      // Release: usar almacenamiento seguro
      await _secureStorage.write(key: _keyToken, value: token);
      await _secureStorage.write(key: _keyRole, value: role);
      if (username != null && username.isNotEmpty) {
        await _secureStorage.write(key: _keyUsername, value: username);
      }
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
      }
    } else {
      // Debug: usar SharedPreferences (rápido, no bloquea)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyRole, role);
      if (username != null && username.isNotEmpty) {
        await prefs.setString(_keyUsername, username);
      }
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await prefs.setString(_keyRefreshToken, refreshToken);
      }
    }
  }

  Future<StoredSession?> loadSession() async {
    if (_useSecureStorage) {
      // Release: leer de almacenamiento seguro
      final token = await _secureStorage.read(key: _keyToken);
      final role = await _secureStorage.read(key: _keyRole);
      if (token == null || token.isEmpty || role == null || role.isEmpty) {
        return null;
      }
      final username = await _secureStorage.read(key: _keyUsername);
      final refreshToken = await _secureStorage.read(key: _keyRefreshToken);
      return StoredSession(token: token, role: role, username: username, refreshToken: refreshToken);
    } else {
      // Debug: leer de SharedPreferences (instantáneo)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyToken);
      final role = prefs.getString(_keyRole);
      if (token == null || token.isEmpty || role == null || role.isEmpty) {
        return null;
      }
      final username = prefs.getString(_keyUsername);
      final refreshToken = prefs.getString(_keyRefreshToken);
      return StoredSession(token: token, role: role, username: username, refreshToken: refreshToken);
    }
  }

  Future<void> clearSession() async {
    if (_useSecureStorage) {
      await _secureStorage.delete(key: _keyToken);
      await _secureStorage.delete(key: _keyRole);
      await _secureStorage.delete(key: _keyUsername);
      await _secureStorage.delete(key: _keyRefreshToken);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyRole);
      await prefs.remove(_keyUsername);
      await prefs.remove(_keyRefreshToken);
    }
    CurrentUser.clear();
  }
}
