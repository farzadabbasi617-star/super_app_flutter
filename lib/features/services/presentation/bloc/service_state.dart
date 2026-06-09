import 'package:equatable/equatable.dart';
import '../../domain/entities/service_request.dart';

abstract class ServiceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}
class ServiceSearching extends ServiceState {
  final ServiceRequest request;
  ServiceSearching(this.request);
  @override
  List<Object?> get props => [request];
}
class ServiceProfessionalAssigned extends ServiceState {
  final ServiceRequest request;
  ServiceProfessionalAssigned(this.request);
  @override
  List<Object?> get props => [request];
}
class ServiceOnTheWay extends ServiceState {
  final ServiceRequest request;
  ServiceOnTheWay(this.request);
  @override
  List<Object?> get props => [request];
}
class ServiceCompleted extends ServiceState {}
class ServiceFailure extends ServiceState {
  final String error;
  ServiceFailure(this.error);
  @override
  List<Object?> get props => [error];
}
