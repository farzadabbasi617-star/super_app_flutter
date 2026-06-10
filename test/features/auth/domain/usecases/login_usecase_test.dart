import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:super_app_flutter/features/auth/domain/entities/user.dart';
import 'package:super_app_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:super_app_flutter/core/error/failures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUseCase(mockRepository);
  });

  test('should return User when login is successful', () async {
    // Arrange
    final tUser = User(id: '1', email: 'test@test.com', fullName: 'Test', phoneNumber: '123', role: UserRole.customer);
    when(mockRepository.login(any, any)).thenAnswer((_) async => Right(tUser));

    // Act
    final result = await usecase.execute('test@test.com', 'password123');

    // Assert
    expect(result, Right(tUser));
    verify(mockRepository.login('test@test.com', 'password123')).called(1);
  });

  test('should return Failure when login fails', () async {
    // Arrange
    when(mockRepository.login(any, any)).thenAnswer((_) async => Left(ServerFailure('Invalid credentials')));

    // Act
    final result = await usecase.execute('wrong@test.com', 'wrongpass');

    // Assert
    expect(result, Left(ServerFailure('Invalid credentials')));
  });
}
