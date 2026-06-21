import 'package:dartz/dartz.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';
import 'package:super_app_flutter/core/error/failures.dart';

class GetShopDetailsUseCase {
  final ShopRepository repository;
  GetShopDetailsUseCase(this.repository);

  Future<Either<Failure, Shop>> execute(String shopId) async {
    try {
      final shop = await repository.getShopDetails(shopId);
      return Right(shop);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
