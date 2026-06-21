import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_app_flutter/core/error/failures.dart';
import 'package:super_app_flutter/features/auth/domain/entities/user.dart';
import 'package:super_app_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/login_usecase.dart';

class FakeAuthRepository implements AuthRepository {
  Either<Failure, User>? loginResult;
  int loginCallCount = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    loginCallCount++;
    lastEmail = email;
    lastPassword = password;
    return loginResult!;
  }

  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String fullName,
    String phoneNumber,
    UserRole role,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logout() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() {
    throw UnimplementedError();
  }
}

void main() {
  late LoginUseCase usecase;
  late FakeAuthRepository repository;

  setUp(() {
    repository = FakeAuthRepository();
    usecase = LoginUseCase(repository);
  });

  test('should return User when login is successful', () async {
    const tUser = User(
      id: '1',
      email: 'test@test.com',
      fullName: 'Test',
      phoneNumber: '123',
      role: UserRole.customer,
    );
    repository.loginResult = const Right(tUser);

    final result = await usecase.execute('test@test.com', 'password123');

    expect(result, const Right(tUser));
    expect(repository.loginCallCount, 1);
    expect(repository.lastEmail, 'test@test.com');
    expect(repository.lastPassword, 'password123');
  });

  test('should return Failure when login fails', () async {
    repository.loginResult = const Left(ServerFailure('Invalid credentials'));

    final result = await usecase.execute('wrong@test.com', 'wrongpass');

    expect(result, const Left(ServerFailure('Invalid credentials')));
  });
}
