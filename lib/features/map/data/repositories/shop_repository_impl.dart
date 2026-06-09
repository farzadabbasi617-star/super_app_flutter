import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  @override
  Future<List<Shop>> getNearbyShops(LatLng userLocation) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      const Shop(
        id: 's1', 
        name: 'Tech Hub', 
        description: 'Best electronics in town', 
        location: LatLng(35.6892, 51.3890), 
        imageUrl: 'https://via.placeholder.com/150', 
        category: 'Electronics', 
        rating: 4.8
      ),
      const Shop(
        id: 's2', 
        name: 'Green Garden', 
        description: 'Fresh organic plants', 
        location: LatLng(35.6950, 51.3950), 
        imageUrl: 'https://via.placeholder.com/150', 
        category: 'Plants', 
        rating: 4.5
      ),
      const Shop(
        id: 's3', 
        name: 'Coffee Corner', 
        description: 'Premium roasted coffee', 
        location: LatLng(35.6800, 51.3700), 
        imageUrl: 'https://via.placeholder.com/150', 
        category: 'Cafe', 
        rating: 4.9
      ),
    ];
  }

  @override
  Future<Shop> getShopDetails(String shopId) async {
    return const Shop(
      id: 's1', 
      name: 'Tech Hub', 
      description: 'Best electronics in town. We provide the latest gadgets and expert repair services.', 
      location: LatLng(35.6892, 51.3890), 
      imageUrl: 'https://via.placeholder.com/150', 
      category: 'Electronics', 
      rating: 4.8
    );
  }
}
