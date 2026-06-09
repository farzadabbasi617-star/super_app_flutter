import '../entities/product.dart';
import '../../../core/error/failures.dart';

abstract class RentalRepository {
  Future<Either<Failure, bool>> bookEquipment({
    required String productId,
    required DateTime startDate,
    required DateTime endDate,
  });
}

class Either<L, R> {
  final L left;
  final R right;
  Either.left(this.left) : right = null as dynamic;
  Either.right(this.right) : left = null as dynamic;
  bool get isLeft => left != null;
  bool get isRight => right != null;
}
