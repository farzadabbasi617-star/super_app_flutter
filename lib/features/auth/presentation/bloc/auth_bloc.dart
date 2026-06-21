import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await loginUseCase.execute(event.email, event.password);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    }, transformer: restartable());

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await registerUseCase.execute(
        event.email,
        event.password,
        event.fullName,
        event.phoneNumber,
        event.role,
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    }, transformer: restartable());

    on<AuthLogoutRequested>((event, emit) async {
      final result = await logoutUseCase.execute();
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(AuthUnauthenticated()),
      );
    }, transformer: sequential());
  }
}
