import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/network_client.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/map/data/repositories/shop_repository_impl.dart';
import '../../features/map/domain/repositories/shop_repository.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';
import '../../features/services/data/repositories/service_repository_impl.dart';
import '../../features/services/domain/repositories/service_repository.dart';
import '../../features/services/presentation/bloc/service_bloc.dart';
import '../network/socket/socket_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => NetworkClient(sl()));
  sl.registerLazySingleton<SocketService>(() => SocketService());

  // Auth
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // Map/Shop
  sl.registerLazySingleton<ShopRepository>(() => ShopRepositoryImpl());
  sl.registerFactory(() => MapBloc(shopRepository: sl()));

  // Services
  sl.registerLazySingleton<ServiceRepository>(() => ServiceRepositoryImpl(sl()));
  sl.registerFactory(() => ServiceBloc(serviceRepository: sl()));
  
  print("Service Locator Initialized");
}
