import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNearbyShopsRequested extends MapEvent {
  final LatLng userLocation;
  LoadNearbyShopsRequested(this.userLocation);
  @override
  List<Object?> get props => [userLocation];
}

class ShopSelected extends MapEvent {
  final String shopId;
  ShopSelected(this.shopId);
  @override
  List<Object?> get props => [shopId];
}
