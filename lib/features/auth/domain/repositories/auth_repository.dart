import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import 'package:super_app_flutter/core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String fullName,
    String phoneNumber,
    UserRole role,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser();
}
