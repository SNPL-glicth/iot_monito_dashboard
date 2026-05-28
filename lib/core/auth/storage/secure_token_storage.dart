import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_storage_interface.dart';

class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}

class SecureTokenStorage implements IAuthStorage {
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  final FlutterSecureStorage _storage;

  SecureTokenStorage({required FlutterSecureStorage storage})
      : _storage = storage;

  @override
  Future<void> saveAccessToken(String token) async {
    await _write(_keyAccessToken, token);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _write(_keyRefreshToken, token);
  }

  @override
  Future<String?> readAccessToken() async {
    return _read(_keyAccessToken);
  }

  @override
  Future<String?> readRefreshToken() async {
    return _read(_keyRefreshToken);
  }

  @override
  Future<void> deleteAllTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw StorageException('Failed to write $key: $e');
    }
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw StorageException('Failed to read $key: $e');
    }
  }
}
