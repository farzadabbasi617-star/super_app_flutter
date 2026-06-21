import 'package:dartz/dartz.dart';
import '../../domain/repositories/service_repository.dart';
import 'package:super_app_flutter/core/error/failures.dart';

class AcceptServiceRequestUseCase {
  final ServiceRepository repository;
  AcceptServiceRequestUseCase(this.repository);

  Future<Either<Failure, void>> execute(
    String requestId,
    String professionalId,
  ) async {
    try {
      await repository.acceptRequest(requestId, professionalId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
