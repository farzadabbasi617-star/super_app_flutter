import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;

  AuthRepositoryImpl(this.dio);

  @override
  Future<User> login(String email, String password) async {
    // Simulating network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful login
    return const User(
      id: '1', 
      email: 'farzad@example.com', 
      fullName: 'Farzad Abbasi', 
      phoneNumber: '09123456789'
    );
  }

  @override
  Future<User> register(String email, String password, String fullName, String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    return User(id: '2', email: email, fullName: fullName, phoneNumber: phoneNumber);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<User?> getCurrentUser() async {
    return null; // Not logged in by default
  }
}
