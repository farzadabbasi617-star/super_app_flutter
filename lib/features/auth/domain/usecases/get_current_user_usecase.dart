import 'package:dartz/dartz.dart';
import 'package:super_app_flutter/core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, User?>> execute() async {
    return await repository.getCurrentUser();
  }
}
