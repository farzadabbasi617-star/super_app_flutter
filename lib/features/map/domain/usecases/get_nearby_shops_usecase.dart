import 'package:dartz/dartz.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';
import '../../../core/error/failures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetNearbyShopsUseCase {
  final ShopRepository repository;
  GetNearbyShopsUseCase(this.repository);

  Future<Either<Failure, List<Shop>>> execute(LatLng userLocation) async {
    try {
      final shops = await repository.getNearbyShops(userLocation);
      return Right(shops);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
