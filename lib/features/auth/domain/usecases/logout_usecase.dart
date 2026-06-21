import 'package:dartz/dartz.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:super_app_flutter/core/error/failures.dart';

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> execute() async {
    return await repository.logout();
  }
}
