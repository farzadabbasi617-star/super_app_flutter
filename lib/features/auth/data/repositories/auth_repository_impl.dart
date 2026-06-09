import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;

  AuthRepositoryImpl(this.dio);

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mocking a customer login
    return const User(
      id: '1', 
      email: 'farzad@example.com', 
      fullName: 'Farzad Abbasi', 
      phoneNumber: '09123456789',
      role: UserRole.customer
    );
  }

  @override
  Future<User> register(String email, String password, String fullName, String phoneNumber, UserRole role) async {
    await Future.delayed(const Duration(seconds: 1));
    return User(id: '2', email: email, fullName: fullName, phoneNumber: phoneNumber, role: role);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<User?> getCurrentUser() async {
    return null;
  }
}
