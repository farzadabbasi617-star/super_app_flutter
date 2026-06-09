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
import '../../features/marketplace/data/repositories/product_repository_impl.dart';
import '../../features/marketplace/domain/repositories/product_repository.dart';
import '../../features/marketplace/data/repositories/rental_repository_impl.dart';
import '../../features/marketplace/domain/repositories/rental_repository.dart';
import '../../features/marketplace/presentation/bloc/product_bloc.dart';
import '../../features/marketplace/presentation/bloc/rental_bloc.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => NetworkClient(sl()));
  sl.registerLazySingleton<SocketService>(() => SocketService());
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton<ShopRepository>(() => ShopRepositoryImpl());
  sl.registerFactory(() => MapBloc(shopRepository: sl()));
  sl.registerLazySingleton<ServiceRepository>(() => ServiceRepositoryImpl(sl()));
  sl.registerFactory(() => ServiceBloc(serviceRepository: sl()));
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl());
  sl.registerLazySingleton<RentalRepository>(() => RentalRepositoryImpl());
  sl.registerFactory(() => ProductBloc(productRepository: sl()));
  sl.registerFactory(() => RentalBloc(rentalRepository: sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));
  sl.registerFactory(() => ProfileBloc(profileRepository: sl()));
  sl.registerLazySingleton<PaymentRepository>(() => PaymentRepositoryImpl(sl()));
  
  print("Professional Service Locator Initialized");
}
