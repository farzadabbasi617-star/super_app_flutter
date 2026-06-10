import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:super_app_flutter/features/auth/domain/entities/user.dart';
import 'package:super_app_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/register_usecase.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/logout_//usecase.dart';
import 'package:super_app_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:super_app_flutter/features/auth/presentation/bloc/auth_event.dart';
import 'package:super_app_flutter/features/auth/presentation/bloc/auth_state.dart';
import 'package:super_app_flutter/core/error/failures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc - Login', () {
    final tUser = User(id: '1', email: 'test@test.com', fullName: 'Test', phoneNumber: '123', role: UserRole.customer);

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when login is successful',
      build: () {
        when(mockLoginUseCase.execute(any, any)).thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested('test@test.com', 'password123')),
      expect: () => [AuthLoading(), AuthAuthenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthFailure] when login fails',
      build: () {
        when(mockLoginUseCase.execute(any, any)).thenAnswer((_) async => Left(ServerFailure('Invalid credentials')));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested('wrong@test.com', 'wrongpass')),
      expect: () => [AuthLoading(), AuthFailure('Invalid credentials')],
    );
  });
}
