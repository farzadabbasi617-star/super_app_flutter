import 'package:dartz/dartz.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import 'package:super_app_flutter/core/error/failures.dart';
import 'package:dio/dio.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final Dio dio;
  double _currentBalance = 1250.0;

  ProfileRepositoryImpl(this.dio);

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return Right(
        const UserProfile(
          uid: 'u123',
          fullName: 'Farzad Abbasi',
          email: 'farzad@example.com',
          phoneNumber: '+989123456789',
          avatarUrl: 'https://via.placeholder.com/150',
          walletBalance: 1250.0,
          interests: ['Electronics', 'Industrial Tools'],
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(null);
  }

  @override
  Future<Either<Failure, double>> updateWalletBalance(double amount) async {
    _currentBalance += amount;
    return Right(_currentBalance);
  }
}
