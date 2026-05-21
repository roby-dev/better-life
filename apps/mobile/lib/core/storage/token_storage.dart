import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> delete();
}

/// Production implementation backed by [FlutterSecureStorage].
/// Uses Android EncryptedSharedPreferences for hardware-backed encryption.
/// IMPORTANT: never logs the token value at any level.
class FlutterSecureStorageTokenStorage implements TokenStorage {
  static const _key = 'auth_token';

  final FlutterSecureStorage _storage;

  FlutterSecureStorageTokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } catch (e) {
      // Log error message only — never the token value.
      debugPrint('[TokenStorage] read failed: ${e.runtimeType}');
      return null;
    }
  }

  @override
  Future<void> write(String token) async {
    try {
      await _storage.write(key: _key, value: token);
    } catch (e) {
      debugPrint('[TokenStorage] write failed: ${e.runtimeType}');
    }
  }

  @override
  Future<void> delete() async {
    try {
      await _storage.delete(key: _key);
    } catch (e) {
      debugPrint('[TokenStorage] delete failed: ${e.runtimeType}');
    }
  }
}

/// In-memory implementation for tests.
/// Never involves platform channels or logging.
class InMemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> delete() async => _token = null;
}
