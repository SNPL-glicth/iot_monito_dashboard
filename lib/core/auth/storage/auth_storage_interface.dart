abstract class IAuthStorage {
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> deleteAllTokens();
}
