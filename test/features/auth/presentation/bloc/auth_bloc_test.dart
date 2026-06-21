import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_app_flutter/core/error/failures.dart';
import 'package:super_app_flutter/features/auth/domain/entities/user.dart';
import 'package:super_app_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/logout_usecase.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/register_usecase.dart';
import 'package:super_app_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:super_app_flutter/features/auth/presentation/bloc/auth_event.dart';
import 'package:super_app_flutter/features/auth/presentation/bloc/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  Either<Failure, User>? loginResult;
  Either<Failure, User>? registerResult;
  Either<Failure, void>? logoutResult;
  Either<Failure, User?>? currentUserResult;

  @override
  Future<Either<Failure, User>> login(String email, String password) async =>
      loginResult!;

  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String fullName,
    String phoneNumber,
    UserRole role,
  ) async => registerResult!;

  @override
  Future<Either<Failure, void>> logout() async =>
      logoutResult ?? const Right(null);

  @override
  Future<Either<Failure, User?>> getCurrentUser() async =>
      currentUserResult ?? const Right(null);
}

void main() {
  late FakeAuthRepository repository;

  AuthBloc buildBloc() {
    return AuthBloc(
      loginUseCase: LoginUseCase(repository),
      registerUseCase: RegisterUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      getCurrentUserUseCase: GetCurrentUserUseCase(repository),
    );
  }

  setUp(() {
    repository = FakeAuthRepository();
  });

  group('AuthBloc - Status check', () {
    const tUser = User(
      id: '1',
      email: 'test@test.com',
      fullName: 'Test',
      phoneNumber: '123',
      role: UserRole.customer,
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when a cached user exists',
      build: () {
        repository.currentUserResult = const Right(tUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(AuthStatusChecked()),
      expect: () => [AuthLoading(), AuthAuthenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthUnauthenticated] when no cached user exists',
      build: () {
        repository.currentUserResult = const Right(null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(AuthStatusChecked()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
    );
  });

  group('AuthBloc - Login', () {
    const tUser = User(
      id: '1',
      email: 'test@test.com',
      fullName: 'Test',
      phoneNumber: '123',
      role: UserRole.customer,
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when login is successful',
      build: () {
        repository.loginResult = const Right(tUser);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(AuthLoginRequested('test@test.com', 'password123')),
      expect: () => [AuthLoading(), AuthAuthenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthFailure] when login fails',
      build: () {
        repository.loginResult = const Left(
          ServerFailure('Invalid credentials'),
        );
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(AuthLoginRequested('wrong@test.com', 'wrongpass')),
      expect: () => [AuthLoading(), AuthFailure('Invalid credentials')],
    );
  });
}
