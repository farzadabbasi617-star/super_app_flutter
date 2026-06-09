import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum ServiceStatus { pending, searching, offerReceived, accepted, onTheWay, completed, cancelled }

class ServiceRequest extends Equatable {
  final String id;
  final String customerId;
  final String? professionalId;
  final String serviceType;
  final LatLng location;
  final ServiceStatus status;
  final DateTime createdAt;

  const ServiceRequest({
    required this.id,
    required this.customerId,
    this.professionalId,
    required this.serviceType,
    required this.location,
    required this.status,
    required this.createdAt,
  });

  ServiceRequest copyWith({
    String? professionalId,
    ServiceStatus? status,
  }) {
    return ServiceRequest(
      id: id,
      customerId: customerId,
      professionalId: professionalId ?? this.professionalId,
      serviceType: serviceType,
      location: location,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, customerId, professionalId, serviceType, location, status, createdAt];
}
