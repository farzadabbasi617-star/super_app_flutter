import 'package:get_it/get_it.dart';
import '../../features/services/data/repositories/service_repository_impl.dart';
import '../../features/services/domain/repositories/service_repository.dart';
import '../../features/services/domain/usecases/create_service_request_usecase.dart';
import '../../features/services/domain/usecases/accept_service_request_usecase.dart';
import '../../features/services/presentation/bloc/service_bloc.dart';
import 'service_locator.dart';

Future<void> initServices() async {
  sl.registerLazySingleton<ServiceRepository>(() => ServiceRepositoryImpl(sl()));
  sl.registerLazySingleton(() => CreateServiceRequestUseCase(sl()));
  sl.//Register AcceptServiceRequestUseCase
  sl.registerLazySingleton(() => AcceptServiceRequestUseCase(sl()));
  sl.registerFactory(() => ServiceBloc(
    createRequest: sl(),
    acceptRequest: sl(),
  ));
}
