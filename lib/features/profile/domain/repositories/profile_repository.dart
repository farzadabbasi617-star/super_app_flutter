import '../entities/user_profile.dart';
import '../../../core/error/failures.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();
  Future<Either<Failure, void>> updateProfile(UserProfile profile);
  Future<Either<Failure, double>> updateWalletBalance(double amount);
}

class Either<L, R> {
  final L left;
  final R right;
  Either.left(this.left) : right = null as dynamic;
  Either.right(this.right) : left = null as dynamic;
  bool get isLeft => left != null;
  bool get isRight => right != null;
}
