import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iot_monito_dashboard/core/auth/storage/secure_token_storage.dart';

class MockFlutterSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #write) {
      final key = invocation.namedArguments[const Symbol('key')] as String;
      final value = invocation.namedArguments[const Symbol('value')] as String?;
      if (value != null) _store[key] = value;
      return Future<void>.value();
    }
    if (invocation.memberName == #read) {
      final key = invocation.namedArguments[const Symbol('key')] as String;
      return Future<String?>.value(_store[key]);
    }
    if (invocation.memberName == #delete) {
      final key = invocation.namedArguments[const Symbol('key')] as String;
      _store.remove(key);
      return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  group('SecureTokenStorage', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureTokenStorage storage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      storage = SecureTokenStorage(storage: mockStorage);
    });

    test('save and read access token', () async {
      await storage.saveAccessToken('access-123');
      final result = await storage.readAccessToken();
      expect(result, 'access-123');
    });

    test('save and read refresh token', () async {
      await storage.saveRefreshToken('refresh-456');
      final result = await storage.readRefreshToken();
      expect(result, 'refresh-456');
    });

    test('deleteAllTokens clears both tokens', () async {
      await storage.saveAccessToken('access-123');
      await storage.saveRefreshToken('refresh-456');
      await storage.deleteAllTokens();
      expect(await storage.readAccessToken(), isNull);
      expect(await storage.readRefreshToken(), isNull);
    });
  });
}
