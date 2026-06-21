import 'package:dartz/dartz.dart';
import 'package:super_app_flutter/core/error/failures.dart';

abstract class RentalRepository {
  Future<Either<Failure, bool>> bookEquipment({
    required String productId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
