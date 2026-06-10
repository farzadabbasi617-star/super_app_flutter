import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../domain/usecases/create_service_request_usecase.dart';
import '../../domain/usecases/accept_service_request_usecase.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final CreateServiceRequestUseCase createRequest;
  final AcceptServiceRequestUseCase acceptRequest;

  ServiceBloc({required this.createRequest, required this.acceptRequest}) : super(ServiceInitial()) {
    on<RequestServiceStarted>((event, emit) async {
      emit(ServiceSearching());
      final result = await createRequest.execute(event.request);
      result.fold(
        (failure) => emit(ServiceFailure(failure.message)),
        (_) => null, / Status updates are handled by the stream in a real app
      );
    }, transformer: restartable());

    on<AcceptRequestRequested>((event, emit) async {
      final result = await acceptRequest.execute(event.requestId, event.professionalId);
      result.fold(
        (failure) => emit(ServiceFailure(failure.message)),
        (_) => null,
      );
    }, transformer: sequential());
  }
}
