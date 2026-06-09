import '../entities/transaction.dart';
import '../../../core/error/failures.dart';

abstract class PaymentRepository {
  Future<Either<Failure, Transaction>> processPayment(double amount, String description);
  Future<Either<Failure, List<Transaction>>> getTransactionHistory();
}

class Either<L, R> {
  final L left;
  final R right;
  Either.left(this.left) : right = null as dynamic;
  Either.right(this.right) : left = null as dynamic;
  bool get isLeft => left != null;
  bool get isRight => right != null;
}
