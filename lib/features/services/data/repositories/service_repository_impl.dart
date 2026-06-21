import 'dart:async';
import '../../domain/entities/service_request.dart';
import '../../domain/repositories/service_repository.dart';
import 'package:super_app_flutter/core/network/socket/socket_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final SocketService _socketService;

  ServiceRepositoryImpl(this._socketService);

  @override
  Future<void> createRequest(ServiceRequest request) async {
    // 1. API call to create request in DB
    // 2. Socket emit to notify nearby professionals
    await _socketService.emitWithAck('request_service', {
      'requestId': request.id,
      'location': {
        'lat': request.location.latitude,
        'lng': request.location.longitude,
      },
      'serviceType': request.serviceType,
    });
  }

  @override
  Future<void> acceptRequest(String requestId, String professionalId) async {
    await _socketService.emitWithAck('accept_request', {
      'requestId': requestId,
      'professionalId': professionalId,
    });
  }

  @override
  Future<void> updateStatus(String requestId, ServiceStatus status) async {
    await _socketService.emitWithAck('update_status', {
      'requestId': requestId,
      'status': status.name,
    });
  }

  @override
  Stream<ServiceRequest> watchRequestStatus(String requestId) {
    final controller = StreamController<ServiceRequest>.broadcast();

    _socketService.listen('status_update', (data) {
      if (data['requestId'] == requestId) {
        controller.add(
          ServiceRequest(
            id: requestId,
            customerId: 'user123',
            serviceType: data['type'] ?? 'Unknown',
            location: const LatLng(35.6892, 51.3890),
            status: ServiceStatus.values.firstWhere(
              (e) => e.name == data['status'],
            ),
            createdAt: DateTime.now(),
            estimatedArrivalTime: (data['eta'] as num?)?.toDouble() ?? 0.0,
          ),
        );
      }
    });

    return controller.stream;
  }

  @override
  Stream<ServiceRequest> watchIncomingRequests() {
    final controller = StreamController<ServiceRequest>.broadcast();

    _socketService.listen('new_request_available', (data) {
      controller.add(
        ServiceRequest(
          id: data['requestId'],
          customerId: data['customerId'],
          serviceType: data['type'],
          location: LatLng(data['lat'], data['lng']),
          status: ServiceStatus.searching,
          createdAt: DateTime.now(),
        ),
      );
    });

    return controller.stream;
  }
}
