import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final UserRole role;
  AuthRegisterRequested(
    this.email,
    this.password,
    this.fullName,
    this.phoneNumber,
    this.role,
  );
  @override
  List<Object?> get props => [email, password, fullName, phoneNumber, role];
}

class AuthLogoutRequested extends AuthEvent {}
