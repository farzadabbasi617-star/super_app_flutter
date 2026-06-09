import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/shop_repository.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final ShopRepository shopRepository;

  MapBloc({required this.shopRepository}) : super(MapInitial()) {
    on<LoadNearbyShopsRequested>((event, emit) async {
      emit(MapLoading());
      try {
        final shops = await shopRepository.getNearbyShops(event.userLocation);
        emit(MapLoaded(shops));
      } catch (e) {
        emit(MapFailure(e.toString()));
      }
    });
    
    on<ShopSelected>((event, emit) {
      // handled in UI
    });
  }
}
