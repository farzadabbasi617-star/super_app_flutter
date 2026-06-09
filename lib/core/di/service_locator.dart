import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/map/data/repositories/shop_repository_impl.dart';
import '../../features/map/domain/repositories/shop_repository.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => Dio());

  // Auth
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // Map/Shop
  sl.registerLazySingleton<ShopRepository>(() => ShopRepositoryImpl());
  sl.registerFactory(() => MapBloc(shopRepository: sl()));
  
  print("Service Locator Initialized");
}
