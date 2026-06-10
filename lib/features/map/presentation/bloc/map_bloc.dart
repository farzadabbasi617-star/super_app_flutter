import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_nearby_shops_usecase.dart';
import '../../domain/usecases/get_shop_details_usecase.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetNearbyShopsUseCase getNearbyShops;
  final GetShopDetailsUseCase getShopDetails;

  MapBloc({required this.getNearbyShops, required this.getShopDetails}) : super(MapInitial()) {
    on<LoadNearbyShopsRequested>((event, emit) async {
      emit(MapLoading());
      final result = await getNearbyShops.execute(event.userLocation);
      result.fold(
        (failure) => emit(MapFailure(failure.message)),
        (shops) => emit(MapLoaded(shops)),
      );
    });
    
    on<ShopSelected>((event, emit) async {
      // Logic for handling shop selection via getShopDetails
    });
  }
}
