import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  ProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileFailure extends ProfileState {
  final String error;
  ProfileFailure(this.error);
  @override
  List<Object?> get props => [error];
}
