import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_app_flutter/features/map/domain/entities/shop.dart';
import 'package:super_app_flutter/features/map/domain/repositories/shop_repository.dart';
import 'package:super_app_flutter/features/map/domain/usecases/get_nearby_shops_usecase.dart';

class FakeShopRepository implements ShopRepository {
  List<Shop> nearbyShops = const [];
  LatLng? lastLocation;

  @override
  Future<List<Shop>> getNearbyShops(LatLng userLocation) async {
    lastLocation = userLocation;
    return nearbyShops;
  }

  @override
  Future<Shop> getShopDetails(String shopId) {
    throw UnimplementedError();
  }
}

void main() {
  late GetNearbyShopsUseCase usecase;
  late FakeShopRepository repository;

  setUp(() {
    repository = FakeShopRepository();
    usecase = GetNearbyShopsUseCase(repository);
  });

  test('should return a list of shops when coordinates are valid', () async {
    const tShops = [
      Shop(
        id: '1',
        name: 'Shop 1',
        description: '...',
        location: LatLng(0, 0),
        imageUrl: '...',
        category: 'A',
        rating: 4.0,
        reviewCount: 10,
        address: '...',
        phoneNumber: '...',
        website: '...',
        isOpen: true,
        operatingHours: '...',
      ),
    ];
    repository.nearbyShops = tShops;

    final result = await usecase.execute(const LatLng(0, 0));

    expect(result, const Right(tShops));
    expect(repository.lastLocation, const LatLng(0, 0));
  });
}
