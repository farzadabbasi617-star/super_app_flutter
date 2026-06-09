import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    
    // Using 'restartable' for login: If a new login request comes while one is pending,
    // the previous one is cancelled and the new one starts. This prevents multiple 
    // simultaneous login attempts.
    on<AuthLoginRequested>(
      (event, emit) async {
        emit(AuthLoading());
        try {
          final user = await authRepository.login(event.email, event.password);
          emit(AuthAuthenticated(user));
        } catch (e) {
          emit(AuthFailure(e.toString()));
        }
      }, 
      transformer: restartable(),
    );

    // Using 'restartable' for registration as well
    on<AuthRegisterRequested>(
      (event, emit) async {
        emit(AuthLoading());
        try {
          final user = await authRepository.register(event.email, event.password, event.fullName, event.phoneNumber);
          emit(AuthAuthenticated(user));
        } catch (e) {
          emit(AuthFailure(e.toString()));
        }
      }, 
      transformer: restartable(),
    );

    // Using 'sequential' for logout to ensure it completes before any other auth action
    on<AuthLogoutRequested>(
      (event, emit) async {
        try {
          await authRepository.logout();
          emit(AuthUnauthenticated());
        } catch (e) {
          emit(AuthFailure('Logout failed: ${e.toString()}'));
        }
      }, 
      transformer: sequential(),
    );
  }
}
