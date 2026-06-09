import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String fullName, String phoneNumber, UserRole role);
  Future<void> logout();
  Future<User?> getCurrentUser();
}
