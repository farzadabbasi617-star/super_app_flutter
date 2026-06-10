import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum ServiceStatus { 
  pending,      / Created but not yet dispatched
  searching,    / Dispatched to nearby professionals
  offerReceived, / One or more professionals expressed interest
  accepted,     / A professional has been officially assigned
  onTheWay,     / Professional is moving towards the customer
  completed,    / Service finished
  cancelled     / Cancelled by either party
}

class ServiceRequest extends Equatable {
  final String id;
  final String customerId;
  final String? professionalId;
  final String serviceType;
  final LatLng location;
  final ServiceStatus status;
  final DateTime createdAt;
  final double estimatedArrivalTime; / in minutes

  const ServiceRequest({
    required this.id,
    required this.customerId,
    this.professionalId,
    required this.serviceType,
    required this.location,
    required this.status,
    required this.createdAt,
    this.estimatedArrivalTime = 0.0,
  });

  ServiceRequest copyWith({
    String? professionalId,
    ServiceStatus? status,
    double? estimatedArrivalTime,
  }) {
    return ServiceRequest(
      id: id,
      customerId: customerId,
      professionalId: professionalId ?? this.professionalId,
      serviceType: serviceType,
      location: location,
      status: status ?? this.status,
      createdAt: createdAt,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
    );
  }

  @override
  List<Object?> get props => [id, customerId, professionalId, serviceType, location, status, createdAt, estimatedArrivalTime];
}
