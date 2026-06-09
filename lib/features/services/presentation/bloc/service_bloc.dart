import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/service_repository.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository serviceRepository;

  ServiceBloc({required this.serviceRepository}) : super(ServiceInitial()) {
    on<RequestServiceStarted>((event, emit) async {
      emit(ServiceSearching());
      try {
        await serviceRepository.createRequest(event.request);
      } catch (e) {
        emit(ServiceFailure(e.toString()));
      }
    });

    on<ServiceStatusUpdated>((event, emit) {
      if (event.request.status == ServiceStatus.accepted) {
        emit(ServiceProFound(event.request));
      } else if (event.request.status == ServiceStatus.onTheWay) {
        emit(ServiceOnTheWay(event.request));
      } else if (event.request.status == ServiceStatus.completed) {
        emit(ServiceCompleted());
      }
    });
  }
}
