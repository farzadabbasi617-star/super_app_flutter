import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  // Mocked database of shops, clinics, restaurants, and supermarkets (10 locations total!)
  final List<Shop> _allShops = [
    const Shop(
      id: 's1',
      name: 'Tech Hub',
      description: 'Premium electronics and gadget repair center.',
      location: LatLng(35.6892, 51.3890),
      imageUrl:
          'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=150',
      category: 'Electronics',
      rating: 4.8,
      reviewCount: 124,
      address: 'Tehran, Valiasr St, Block 4',
      phoneNumber: '+982188776655',
      website: 'techhub.ir',
      isOpen: true,
      operatingHours: '۰۹:۰۰ الی ۲۲:۰۰',
    ),
    const Shop(
      id: 's2',
      name: 'Green Garden',
      description: 'Organic plants and landscape design.',
      location: LatLng(35.6950, 51.3950),
      imageUrl:
          'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?w=150',
      category: 'Plants',
      rating: 4.5,
      reviewCount: 89,
      address: 'Tehran, Niavaran Ave, G1',
      phoneNumber: '+982122334455',
      website: 'greengarden.ir',
      isOpen: true,
      operatingHours: '۰۸:۰۰ الی ۲۰:۰۰',
    ),
    const Shop(
      id: 's3',
      name: 'Coffee Corner',
      description: 'Specialty coffee and artisan pastries.',
      location: LatLng(35.6800, 51.3700),
      imageUrl:
          'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=150',
      category: 'Cafe',
      rating: 4.9,
      reviewCount: 210,
      address: 'Tehran, Jordan St, C2',
      phoneNumber: '+982122022211',
      website: 'coffeecorner.ir',
      isOpen: false,
      operatingHours: '۰۷:۰۰ الی ۲۳:۰۰',
    ),
    const Shop(
      id: 's4',
      name: 'Gadget World',
      description: 'Everything tech.',
      location: LatLng(35.6895, 51.3895),
      imageUrl:
          'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=150',
      category: 'Electronics',
      rating: 4.2,
      reviewCount: 50,
      address: 'Tehran, Enghelab Sq',
      phoneNumber: '+982166442211',
      website: 'gadget.ir',
      isOpen: true,
      operatingHours: '۱۰:۰۰ الی ۲۱:۰۰',
    ),
    const Shop(
      id: 's5',
      name: 'Flower Power',
      description: 'Fresh bouquets.',
      location: LatLng(35.6955, 51.3955),
      imageUrl:
          'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?w=150',
      category: 'Plants',
      rating: 4.7,
      reviewCount: 30,
      address: 'Tehran, Pasdaran St',
      phoneNumber: '+982122883344',
      website: 'flower.ir',
      isOpen: true,
      operatingHours: '۰۸:۰۰ الی ۲۰:۰۰',
    ),
    // 3 Fixed Centers (Clinics s6, s7, s8)
    const Shop(
      id: 's6',
      name: 'کلینیک درمانی آریا',
      description: 'In-Clinic treatment, GP, dressings and family health.',
      location: LatLng(35.6810, 51.3910), // adjusted to be on map canvas
      imageUrl:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=150',
      category: 'Clinic',
      rating: 4.8,
      reviewCount: 154,
      address: 'تهران، میدان ونک، بن‌بست آریا، پلاک ۱۲',
      phoneNumber: '+982188999900',
      website: 'ariaclinic.ir',
      isOpen: true,
      operatingHours: '۰۸:۰۰ الی ۲۱:۰۰',
    ),
    const Shop(
      id: 's7',
      name: 'آزمایشگاه تخصصی پایتخت',
      description: 'Medical laboratory, path and check-up services.',
      location: LatLng(35.6940, 51.3850),
      imageUrl:
          'https://images.unsplash.com/photo-1579154204601-01588f351167?w=150',
      category: 'Clinic',
      rating: 4.7,
      reviewCount: 92,
      address: 'تهران، خیابان ولیعصر، تقاطع فاطمی، پلاک ۱۱۰',
      phoneNumber: '+982188908899',
      website: 'paytakhtlab.ir',
      isOpen: true,
      operatingHours: '۰۷:۰۰ الی ۱۹:۰۰',
    ),
    const Shop(
      id: 's8',
      name: 'کلینیک زیبایی بهار',
      description: 'Skincare, laser and rejuvenation clinic.',
      location: LatLng(35.6870, 51.4020),
      imageUrl:
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=150',
      category: 'Clinic',
      rating: 4.6,
      reviewCount: 110,
      address: 'تهران، خیابان نیاوران، پلاک ۱۲، همکف غربی',
      phoneNumber: '+982122802233',
      website: 'baharbeauty.ir',
      isOpen: true,
      operatingHours: '۱۰:۰۰ الی ۲۰:۰۰',
    ),
    // 2 Quick Commerce (Restaurant s9 and Supermarket s10)
    const Shop(
      id: 's9',
      name: 'کباب‌سرای زعفران',
      description: 'Traditional Persian kebab house.',
      location: LatLng(35.6830, 51.3750),
      imageUrl:
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=150',
      category: 'Restaurant',
      rating: 4.8,
      reviewCount: 320,
      address: 'تهران، خیابان ولیعصر، نرسیده به باغ فردوس، پلاک ۱۴',
      phoneNumber: '+982122042205',
      website: 'zafrankebab.ir',
      isOpen: true,
      operatingHours: '۱۲:۰۰ الی ۲۴:۰۰',
    ),
    const Shop(
      id: 's10',
      name: 'سوپرمارکت هایپر پلاس',
      description: '24/7 online grocery and supermarket.',
      location: LatLng(35.6960, 51.3800),
      imageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=150',
      category: 'Supermarket',
      rating: 4.5,
      reviewCount: 412,
      address: 'تهران، خیابان فاطمی، نبش باباطاهر، پلاک ۴۵',
      phoneNumber: '+982188966655',
      website: 'hyperplus.ir',
      isOpen: true,
      operatingHours: 'شبانه‌روزی (۲۴ ساعته)',
    ),
  ];

  @override
  Future<List<Shop>> getNearbyShops(LatLng userLocation) async {
    await Future.delayed(const Duration(seconds: 1));

    // Proximity Filtering (within 15km to match our custom slider range!)
    return _allShops.where((shop) {
      final distance = _calculateDistance(userLocation, shop.location);
      return distance <= 15.0;
    }).toList();
  }

  @override
  Future<Shop> getShopDetails(String shopId) async {
    return _allShops.firstWhere((s) => s.id == shopId);
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const double earthRadius = 6371; // km
    final dLat = (p2.latitude - p1.latitude) * pi / 180;
    final dLon = (p2.longitude - p1.longitude) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(p1.latitude * pi / 180) *
            cos(p2.latitude * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
}
