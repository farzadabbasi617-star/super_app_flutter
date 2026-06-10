import 'package:get_it/get_it.dart';
import '../../features/marketplace/data/repositories/product_repository_impl.dart';
import '../../features/marketplace/domain/repositories/product_repository.dart';
import '../../features/marketplace/domain/usecases/get_products_usecase.dart';
import '../../features/marketplace/data/repositories/rental_repository_impl.dart';
import '../../features/marketplace/domain/repositories/rental_repository.dart';
import '../../features/marketplace/domain/usecases/book_equipment_usecase.dart';
import '../../features/marketplace/presentation/bloc/product_bloc.dart';
import '../../features/marketplace/presentation/bloc/rental_bloc.dart';
import 'service_locator.dart';

Future<void> initMarketplace() async {
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl());
  sl.registerLazySingleton<RentalRepository>(() => RentalRepositoryImpl());
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => BookEquipmentUseCase(sl()));
  sl.registerFactory(() => ProductBloc(getProducts: sl()));
  sl.registerFactory(() => RentalBloc(bookEquipment: sl()));
}
