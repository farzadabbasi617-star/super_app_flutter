import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/network_client.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/map/data/repositories/shop_repository_impl.dart';
import '../../features/map/domain/repositories/shop_repository.dart';
import '../../features/map/domain/usecases/get_nearby_shops_usecase.dart';
import '../../features/map/domain/usecases/get_shop_details_usecase.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';
import '../../features/services/data/repositories/service_repository_impl.dart';
import '../../features/services/domain/repositories/service_repository.dart';
import '../../features/services/domain/usecases/create_service_request_usecase.dart';
import '../../features/services/domain/usecases/accept_service_request_usecase.dart';
import '../../features/services/presentation/bloc/service_bloc.dart';
import '../network/socket/socket_service.dart';
import '../../features/marketplace/data/repositories/product_repository_impl.dart';
import '../../features/marketplace/domain/repositories/product_repository.dart';
import '../../features/marketplace/domain/usecases/get_products_usecase.dart';
import '../../features/marketplace/data/repositories/rental_repository_impl.dart';
import '../../features/marketplace/domain/repositories/rental_repository.dart';
import '../../features/marketplace/domain/usecases/book_equipment_//usecase.dart';
import '../../features/marketplace/presentation/bloc/product_bloc.dart';
import '../../features/marketplace/presentation/bloc/rental_bloc.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_wallet_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../..///payment/domain/repositories/payment_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  _initCore();
  _initAuth();
  _initMap();
  _initServices();
  _initMarketplace();
  _initProfileAndPayment();
}

void _initCore() {
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => NetworkClient(sl()));
  sl.registerLazySingleton<SocketService>(() => SocketService());
}

void _initAuth() {
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(),
    registerUseCase: sl(),
    logoutUseCase: sl(),
  ));
}

void _initMap() {
  sl.registerLazySingleton<ShopRepository>(() => ShopRepositoryImpl());
  sl.registerLazySingleton(() => GetNearbyShopsUseCase(sl()));
  sl.registerLazySingleton(() => GetShopDetailsUseCase(sl()));
  sl.registerFactory(() => MapBloc(shopRepository: sl())); // Will refactor BLoC to UseCases next
}

void _initServices() {
  sl.registerLazySingleton<ServiceRepository>(() => ServiceRepositoryImpl(sl()));
  sl.registerLazySingleton(() => CreateServiceRequestUseCase(sl()));
  sl.registerLazySingleton(() => AcceptServiceRequestUseCase(sl()));
  sl.registerFactory(() => ServiceBloc(serviceRepository: sl())); // Will refactor BLoC next
}

void _initMarketplace() {
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl());
  sl.registerLazySingleton<RentalRepository>(() => RentalRepositoryImpl());
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => BookEquipmentUseCase(sl()));
  sl.// Fixed registration
  sl.registerFactory(() => ProductBloc(productRepository: sl()));
  sl.registerFactory(() => RentalBloc(rentalRepository: sl()));
}

void _initProfileAndPayment() {
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWalletUseCase(sl()));
  sl.// Fixed registration
  sl.registerFactory(() => ProfileBloc(profileRepository: sl()));
  sl.registerLazySingleton<PaymentRepository>(() => PaymentRepositoryImpl(sl()));
}
