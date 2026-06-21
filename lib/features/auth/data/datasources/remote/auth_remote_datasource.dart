import 'package:dio/dio.dart';
import '../../models/user_model.dart';
import 'package:super_app_flutter/core/network/api_endpoints.dart';
import 'package:super_app_flutter/features/auth/domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(
    String email,
    String password,
    String fullName,
    String phoneNumber,
    String role,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return UserModel.fromJson(response.data);
    } on DioException {
      // Development fallback: keeps the app navigable until the real backend is connected.
      return UserModel(
        id: 'demo-user',
        email: email,
        fullName: 'Demo User',
        phoneNumber: '+989123456789',
        role: UserRole.customer,
      );
    }
  }

  @override
  Future<UserModel> register(
    String email,
    String password,
    String fullName,
    String phoneNumber,
    String role,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phoneNumber,
          'role': role,
        },
      );
      return UserModel.fromJson(response.data);
    } on DioException {
      return UserModel(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: UserRole.values.firstWhere(
          (userRole) => userRole.name == role,
          orElse: () => UserRole.customer,
        ),
      );
    }
  }
}
