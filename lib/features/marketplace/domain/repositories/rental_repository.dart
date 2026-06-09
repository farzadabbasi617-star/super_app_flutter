import '../entities/product.dart';

abstract class RentalRepository {
  Future<bool> createRentalOrder({
    required String productId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
