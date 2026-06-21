import 'package:dartz/dartz.dart';
import '../../domain/repositories/rental_repository.dart';
import 'package:super_app_flutter/core/error/failures.dart';

class BookEquipmentUseCase {
  final RentalRepository repository;
  BookEquipmentUseCase(this.repository);

  Future<Either<Failure, bool>> execute({
    required String productId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await repository.bookEquipment(
      productId: productId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
