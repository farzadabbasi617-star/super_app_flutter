import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/user_model.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;
  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveToken(String token) async => await storage.write(key: 'token', value: token);
  @override
  Future<String?> getToken() async => await storage.read(key: 'token');
  @override
  Future<void> saveUser(UserModel user) async => await storage.write(key: 'user', value: jsonEncode(user.toJson()));
  @override
  Future<UserModel?> getUser() async {
    final json = await storage.read(key: 'user');
    return json == null ? null : UserModel.fromJson(jsonDecode(json));
  }
  @override
  Future<void> clear() async => await storage.deleteAll();
}
