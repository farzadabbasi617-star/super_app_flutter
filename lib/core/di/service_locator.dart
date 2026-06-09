import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/network_client.dart';
import '../storage/secure_storage_service.dart';
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
  registerLazySingleton(() => const FlutterSecureStorage());
  registerLazySingleton(() => SecureStorageService(sl()));
  registerLazySingleton(() => Dio());
  registerLazySingleton(() => NetworkClient(sl()));
  registerLazySingleton<SocketService>(() => SocketService());
  registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  registerFactory(() => AuthBloc(authRepository: sl()));
  registerLazySingleton<ShopRepository>(() => ShopRepositoryImpl());
  // Register MapBloc as Factory
  registerFactory(() => MapBloc(shopRepository: sl()));
  registerLazySingleton<ServiceRepository>(() => ServiceRepositoryImpl(sl()));
  registerFactory(() => ServiceBloc(serviceRepository: sl()));
  
  print("Professional Service Locator Initialized");
}
