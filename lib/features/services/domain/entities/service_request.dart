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
  final double estimatedArrivalTime; // in minutes
  final String? assignedProfessionalName;
  final String? assignedProfessionalSpecialty;
  final double? assignedProfessionalRating;
  final double? confirmedPrice;

  const ServiceRequest({
    required this.id,
    required this.customerId,
    this.professionalId,
    required this.serviceType,
    required this.location,
    required this.status,
    required this.createdAt,
    this.estimatedArrivalTime = 0.0,
    this.assignedProfessionalName,
    this.assignedProfessionalSpecialty,
    this.assignedProfessionalRating,
    this.confirmedPrice,
  });

  ServiceRequest copyWith({
    String? professionalId,
    ServiceStatus? status,
    double? estimatedArrivalTime,
    String? assignedProfessionalName,
    String? assignedProfessionalSpecialty,
    double? assignedProfessionalRating,
    double? confirmedPrice,
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
      assignedProfessionalName: assignedProfessionalName ?? this.assignedProfessionalName,
      assignedProfessionalSpecialty: assignedProfessionalSpecialty ?? this.assignedProfessionalSpecialty,
      assignedProfessionalRating: assignedProfessionalRating ?? this.assignedProfessionalRating,
      confirmedPrice: confirmedPrice ?? this.confirmedPrice,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        professionalId,
        serviceType,
        location,
        status,
        createdAt,
        estimatedArrivalTime,
        assignedProfessionalName,
        assignedProfessionalSpecialty,
        assignedProfessionalRating,
        confirmedPrice,
      ];
}
