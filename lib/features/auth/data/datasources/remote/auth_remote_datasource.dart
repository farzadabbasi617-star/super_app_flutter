import 'package:dio/dio.dart';
import '../../models/user_model.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String fullName, String phoneNumber, String role);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await dio.post(ApiEndpoints.login, data: {'email': email, 'password': password});
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> register(String email, String password, String fullName, String phoneNumber, String role) async {
    final response = await dio.post(ApiEndpoints.register, data: {
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone': phoneNumber,
      'role': role,
    });
    return UserModel.fromJson(response.data);
  }
}
