import 'package:dartz/dartz.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../core/error/failures.dart';

class UpdateWalletUseCase {
  final ProfileRepository repository;
  UpdateWalletUseCase(this.repository);

  Future<Either<Failure, double>> execute(double amount) async {
    return await repository.updateWalletBalance(amount);
  }
}
