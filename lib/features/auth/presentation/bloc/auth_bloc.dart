import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.login(event.email, event.password);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.register(event.email, event.password, event.fullName, event.phoneNumber);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    });
  }
}
