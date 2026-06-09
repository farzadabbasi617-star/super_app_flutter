import 'package:equatable/equatable.dart';

enum UserRole { customer, professional, admin }

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final UserRole role;

  const User({
    required this.id, 
    required this.email, 
    required this.fullName, 
    required this.phoneNumber, 
    required this.role
  });

  @override
  List<Object?> get props => [id, email, fullName, phoneNumber, role];
}
