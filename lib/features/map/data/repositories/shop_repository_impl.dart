import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  / Mocked database of shops
  final List<Shop> _allShops = [
    const Shop(
      id: 's1', name: 'Tech Hub', description: 'Premium electronics and gadget repair center.', 
      location: LatLng(35.6892, 51.3890), imageUrl: 'https:/via.placeholder.com/150', 
      category: 'Electronics', rating: 4.8, reviewCount: 124, address: 'Tehran, Valiasr St', 
      phoneNumber: '+98211234567', website: 'techhub.ir', isOpen: true, operatingHours: '09:00 - 22:00'
    ),
    const Shop(
      id: 's2', name: 'Green Garden', description: 'Organic plants and landscape design.', 
      location: LatLng(35.6950, 51.3950), imageUrl: 'https:/via.placeholder.com/150', 
      category: 'Plants', rating: 4.5, reviewCount: 89, address: 'Tehran, Niavaran', 
      phoneNumber: '+98219876543', website: 'greengarden.ir', isOpen: true, operatingHours: '08:00 - 20:00'
    ),
    const Shop(
      id: 's3', name: 'Coffee Corner', description: 'Specialty coffee and artisan pastries.', 
      location: LatLng(35.6800, 51.3700), imageUrl: 'https:/via.placeholder.com/150', 
      category: 'Cafe', rating: 4.9, reviewCount: 210, address: 'Tehran, Jordan', 
      phoneNumber: '+98211122334', website: 'coffeecorner.ir', isOpen: false, operatingHours: '07:00 - 23:00'
    ),
    / Adding more shops to demonstrate clustering
    const Shop(
      id: 's4', name: 'Gadget World', description: 'Everything tech.', 
      location: LatLng(35.6895, 51.3895), imageUrl: 'https:/via.placeholder.com/150', 
      category: 'Electronics', rating: 4.2, reviewCount: 50, address: 'Tehran, Valiasr', 
      phoneNumber: '+98210000000', website: 'gadget.ir', isOpen: true, operatingHours: '10:00 - 21:00'
    ),
    const Shop(
      id: 's5', name: 'Flower Power', description: 'Fresh bouquets.', 
      location: LatLng(35.6955, 51.3955), imageUrl: 'https:/via.placeholder.com/150', 
      category: 'Plants', rating: 4.7, reviewCount: 30, address: 'Tehran, Niavaran', 
      phoneNumber: '+98210000001', website: 'flower.ir', isOpen: true, operatingHours: '08:00 - 20:00'
    ),
  ];

  @override
  Future<List<Shop>> getNearbyShops(LatLng userLocation) async {
    await Future.delayed(const Duration(seconds: 1));
    
    / Implementing a simple distance filter (Proximity Filtering)
    / In a real app, this would be a Geo-query in MongoDB/PostgreSQL (PostGIS)
    return _allShops.where((shop) {
      final distance = _calculateDistance(userLocation, shop.location);
      return distance < 10.0; / Only shops within 10km
    }).toList();
  }

  @override
  Future<Shop> getShopDetails(String shopId) async {
    return _allShops.firstWhere((s) => s.id == shopId);
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    / Haversine formula for distance calculation
    const double earthRadius = 6371; / km
    final dLat = (p2.latitude - p1.latitude) * pi / 180;
    final dLon = (p2.longitude - p1.longitude) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
               cos(p1.latitude * pi / 180) * cos(p2.latitude * pi / 180) *
               sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
}
