import '../entities/service_request.dart';

abstract class ServiceRepository {
  Future<void> createRequest(ServiceRequest request);
  Future<void> acceptRequest(String requestId, String professionalId);
  Future<void> updateStatus(String requestId, ServiceStatus status);
  Stream<ServiceRequest> watchRequestStatus(String requestId);
}
