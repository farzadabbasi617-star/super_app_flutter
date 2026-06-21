import 'package:dartz/dartz.dart';
import '../entities/user_profile.dart';
import 'package:super_app_flutter/core/error/failures.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();
  Future<Either<Failure, void>> updateProfile(UserProfile profile);
  Future<Either<Failure, double>> updateWalletBalance(double amount);
}
