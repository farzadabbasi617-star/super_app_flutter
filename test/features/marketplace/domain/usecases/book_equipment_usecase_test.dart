import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:super_app_flutter/features/marketplace/domain/repositories/rental_repository.dart';
import 'package:super_app_flutter/features/marketplace/domain/usecases/book_equipment_usecase.dart';
import 'package:super_app_flutter/core/error/failures.dart';

class MockRentalRepository extends Mock implements RentalRepository {}

void main() {
  late BookEquipmentUseCase usecase;
  late MockRentalRepository mockRepository;

  setUp(() {
    mockRepository = MockRentalRepository();
    usecase = BookEquipmentUseCase(mockRepository);
  });

  test('should return success when equipment is available', () async {
    // Arrange
    when(mockRepository.bookEquipment(
      productId: anyNamed('productId'),
      startDate: anyNamed('startDate'),
      endDate: anyNamed('endDate'),
    )).thenAnswer((_) async => Right(true));

    // Act
    final result = await usecase.execute(
      productId: 'p1',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 2)),
    );

    // Assert
    expect(result, Right(true));
  });

  test('should return ValidationFailure when dates conflict', () async {
    // Arrange
    when(mockRepository.bookEquipment(
      productId: anyNamed('productId'),
      startDate: anyNamed('startDate'),
      endDate: anyNamed('endDate'),
    )).thenAnswer((_) async => Left(ValidationFailure('Equipment unavailable')));

    // Act
    final result = await usecase.execute(
      productId: 'p1',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 2)),
    );

    // Assert
    expect(result, Left(ValidationFailure('Equipment unavailable')));
  });
}
