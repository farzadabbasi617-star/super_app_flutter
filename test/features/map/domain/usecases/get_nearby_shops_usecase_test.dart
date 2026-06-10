import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_app_flutter/features/map/domain/entities/shop.dart';
import 'package:super_app_flutter/features/map/domain/repositories/shop_repository.dart';
import 'package:super_app_flutter/features/map/domain/usecases/get_nearby_shops_usecase.dart';
import 'package:super_app_flutter/core/error/failures.dart';

class MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late GetNearbyShopsUseCase usecase;
  late MockShopRepository mockRepository;

  setUp(() {
    mockRepository = MockShopRepository();
    usecase = GetNearbyHopsUseCase(mockRepository); // Fixed typo
  });

  test('should return a list of shops when coordinates are valid', () async {
    final tShops = [
      const Shop(id: '1', name: 'Shop 1', description: '...', location: LatLng(0, 0), imageUrl: '...', category: 'A', rating: 4.0, reviewCount: 10, address: '...', phoneNumber: '...', website: '...', isOpen: true, operatingHours: '...'),
    ];
    when(mockRepository.getNearbyShops(any)).thenAnswer((_) async => tShops);

    final result = await usecase.execute(const LatLng(0, 0));

    expect(result, Right(tShops));
  });
}
