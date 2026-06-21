import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_app_flutter/core/error/failures.dart';
import 'package:super_app_flutter/core/theme/app_theme.dart';
import 'package:super_app_flutter/features/auth/domain/entities/user.dart';
import 'package:super_app_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/logout_usecase.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/register_usecase.dart';
import 'package:super_app_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:super_app_flutter/features/auth/presentation/pages/login_page.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, User>> login(String email, String password) async =>
      const Left(ServerFailure('not used'));

  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String fullName,
    String phoneNumber,
    UserRole role,
  ) async =>
      const Left(ServerFailure('not used'));

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<Either<Failure, User?>> getCurrentUser() async => const Right(null);
}

void main() {
  testWidgets('LoginPage should render correctly', (WidgetTester tester) async {
    final repository = FakeAuthRepository();
    final bloc = AuthBloc(
      loginUseCase: LoginUseCase(repository),
      registerUseCase: RegisterUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const LoginPage(),
        ),
      ),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Login'), findsWidgets);

    bloc.close();
  });
}
