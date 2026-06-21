import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:super_app_flutter/core/error/failures.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> execute(
    String email,
    String password,
    String fullName,
    String phoneNumber,
    UserRole role,
  ) async {
    return await repository.register(
      email,
      password,
      fullName,
      phoneNumber,
      role,
    );
  }
}
