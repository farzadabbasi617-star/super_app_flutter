import 'package:equatable/equatable.dart';
import '../../domain/entities/service_request.dart';

abstract class ServiceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RequestServiceStarted extends ServiceEvent {
  final ServiceRequest request;
  RequestServiceStarted(this.request);
  @override
  List<Object?> get props => [request];
}

class ServiceStatusUpdated extends ServiceEvent {
  final ServiceRequest request;
  ServiceStatusUpdated(this.request);
  @override
  List<Object?> get props => [request];
}
