import 'package:dartz/dartz.dart';
import '../../domain/repositories/profile_repository.dart';
import 'package:super_app_flutter/core/error/failures.dart';

class UpdateWalletUseCase {
  final ProfileRepository repository;
  UpdateWalletUseCase(this.repository);

  Future<Either<Failure, double>> execute(double amount) async {
    return await repository.updateWalletBalance(amount);
  }
}
