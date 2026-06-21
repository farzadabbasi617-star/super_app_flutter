import 'package:dartz/dartz.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/repositories/service_repository.dart';
import 'package:super_app_flutter/core/error/failures.dart';

class CreateServiceRequestUseCase {
  final ServiceRepository repository;
  CreateServiceRequestUseCase(this.repository);

  Future<Either<Failure, void>> execute(ServiceRequest request) async {
    try {
      await repository.createRequest(request);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
