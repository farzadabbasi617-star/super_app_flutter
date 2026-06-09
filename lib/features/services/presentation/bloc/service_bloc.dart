import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../domain/repositories/service_repository.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository serviceRepository;

  ServiceBloc({required this.serviceRepository}) : super(ServiceInitial()) {
    
    on<RequestServiceStarted>((event, emit) async {
      try {
        await serviceRepository.createRequest(event.request);
        emit(ServiceSearching(event.request));
        
        // Listen to status updates from the repository (Socket stream)
        await emit.forEach(
          serviceRepository.watchRequestStatus(event.request.id),
          onData: (request) {
            if (request.status == ServiceStatus.accepted) {
              return ServiceProfessionalAssigned(request);
            } else if (request.status == ServiceStatus.onTheWay) {
              return ServiceOnTheWay(request);
            } else if (request.status == ServiceStatus.completed) {
              return ServiceCompleted();
            }
            return ServiceSearching(request);
          },
          onError: (error, stackTrace) => ServiceFailure(error.toString()),
        );
      } catch (e) {
        emit(ServiceFailure(e.toString()));
      }
    }, transformer: restartable());

    on<AcceptRequestRequested>((event, emit) async {
      try {
        await serviceRepository.acceptRequest(event.requestId, event.professionalId);
        // Transition to assigned state
      } catch (e) {
        emit(ServiceFailure(e.toString()));
      }
    }, transformer: sequential());
  }
}
