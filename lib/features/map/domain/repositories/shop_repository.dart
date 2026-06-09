import '../entities/shop.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class ShopRepository {
  Future<List<Shop>> getNearbyShops(LatLng userLocation);
  Future<Shop> getShopDetails(String shopId);
}
