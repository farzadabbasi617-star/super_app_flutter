import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Keys constants to avoid typos
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';

  // Saves the JWT token securely
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // Retrieves the JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Deletes the token (Logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  // Saves user data as a JSON string
  Future<void> saveUser(Map<String, dynamic> user) async {
    final jsonUser = jsonEncode(user);
    await _storage.write(key: _keyUser, value: jsonUser);
  }

  // Retrieves user data
  Future<Map<String, dynamic>?> getUser() async {
    final jsonUser = await _storage.read(key: _keyUser);
    if (jsonUser == null) return null;
    try {
      return jsonDecode(jsonUser) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Clears all secure storage (Factory Reset/Clear Cache)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
