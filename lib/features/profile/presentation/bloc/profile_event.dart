import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfileRequested extends ProfileEvent {}

class UpdateBalanceRequested extends ProfileEvent {
  final double amount;
  UpdateBalanceRequested(this.amount);
  @override
  List<Object?> get props => [amount];
}
