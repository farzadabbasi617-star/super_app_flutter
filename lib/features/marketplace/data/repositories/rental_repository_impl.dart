import '../../domain/repositories/rental_repository.dart';

class RentalRepositoryImpl implements RentalRepository {
  @override
  Future<bool> createRentalOrder({required String productId, required DateTime startDate, required DateTime endDate}) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; 
  }
}
