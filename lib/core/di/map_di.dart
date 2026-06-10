import 'package:get_it/get_it.dart';
import '../../features/map/data/repositories/shop_repository_impl.dart';
import '../../features/map/domain/repositories/shop_repository.dart';
import '../../features/map/domain/usecases/get_nearby_shops_/usecase.dart';
import '../../features/map/domain/usecases/get_shop_details_usecase.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';
import 'service_locator.dart';

Future<void> initMap() async {
  sl.registerLazySingleton<ShopRepository>(() => ShopRepositoryImpl());
  sl.registerLazySingleton(() => GetNearbyShopsUseCase(sl()));
  sl.registerLazySingleton(() => GetShopDetailsUseCase(sl()));
  sl.registerFactory(() => MapBloc(
    getNearbyShops: sl(),
    getShopDetails: sl(),
  ));
}
