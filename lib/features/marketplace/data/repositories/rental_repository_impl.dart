import '../../domain/repositories/rental_repository.dart';
import '../../domain/entities/product.dart';
import '../../../core/error/failures.dart';

class RentalRepositoryImpl implements RentalRepository {
  final List<Product> _products = [
    const Product(
      id: 'p2', name: 'Concrete Mixer', description: 'Heavy duty', price: 5000, 
      imageUrl: '...', category: 'Industrial', isRental: true, rentalPricePerDay: 50,
      unavailableDates: [DateTime(2026, 6, 10), DateTime(2026, 6, 11)],
    ),
  ];

  @override
  Future<Either<Failure, bool>> bookEquipment({
    required String productId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final product = _products.firstWhere((p) => p.id == productId);
    
    for (var date = startDate; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = DateTime(date.year, date.month, date.day + 1)) {
      if (product.unavailableDates.any((uDate) => uDate.year == date.year && uDate.month == date.month && uDate.day == date.day)) {
        return Either.left(ValidationFailure('Equipment unavailable on ${date.toString().split(\' \')[0]}'));
      }
    }
    return Either.right(true);
  }
}
