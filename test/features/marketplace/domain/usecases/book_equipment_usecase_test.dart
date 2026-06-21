import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_app_flutter/core/error/failures.dart';
import 'package:super_app_flutter/features/marketplace/domain/repositories/rental_repository.dart';
import 'package:super_app_flutter/features/marketplace/domain/usecases/book_equipment_usecase.dart';

class FakeRentalRepository implements RentalRepository {
  Either<Failure, bool>? result;

  @override
  Future<Either<Failure, bool>> bookEquipment({
    required String productId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return result!;
  }
}

void main() {
  late BookEquipmentUseCase usecase;
  late FakeRentalRepository repository;

  setUp(() {
    repository = FakeRentalRepository();
    usecase = BookEquipmentUseCase(repository);
  });

  test('should return success when equipment is available', () async {
    repository.result = const Right(true);

    final result = await usecase.execute(
      productId: 'p1',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 2)),
    );

    expect(result, const Right(true));
  });

  test('should return ValidationFailure when dates conflict', () async {
    repository.result = const Left(ValidationFailure('Equipment unavailable'));

    final result = await usecase.execute(
      productId: 'p1',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 2)),
    );

    expect(result, const Left(ValidationFailure('Equipment unavailable')));
  });
}
