import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStorage {
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';

  SessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<String?> readEmail() async {
    try {
      return await _storage.read(key: _emailKey);
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> saveSession(String token, String email) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _emailKey, value: email);
    } catch (_) {
      await clear();
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _emailKey);
    } catch (_) {
      // Ignore exception during clear
    }
  }
}
