import '../../domain/entities/service_request.dart';
import '../../domain/repositories/service_repository.dart';
import '../../../core/network/socket/socket_service.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final SocketService _socketService;

  ServiceRepositoryImpl(this._socketService);

  @override
  Future<void> createRequest(ServiceRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _socketService.emitEvent('request_service', {
      'requestId': request.id,
      'location': {'lat': request.location.latitude, 'lng': request.location.longitude},
      'type': request.serviceType,
    });
  }

  @override
  Future<void> acceptRequest(String requestId, String professionalId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _socketService.emitEvent('accept_request', {
      'requestId': requestId,
      'professionalId': professionalId,
    });
  }

  @override
  Future<void> updateStatus(String requestId, ServiceStatus status) async {
    _socketService.emitEvent('update_status', {
      'requestId': requestId,
      'status': status.name,
    });
  }

  @override
  Stream<ServiceRequest> watchRequestStatus(String requestId) {
    final controller = StreamController<ServiceRequest>();
    _socketService.listenEvent('status_update', (data) {
      if (data['requestId'] == requestId) {
        controller.add(ServiceRequest(
          id: requestId,
          customerId: 'user123',
          serviceType: 'Plumbing',
          location: const LatLng(35.6892, 51.3890),
          status: ServiceStatus.values.firstWhere((e) => e.name == data['status']),
          createdAt: DateTime.now(),
        ));
      }
    });
    return controller.stream;
  }
}
