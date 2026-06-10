import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../core/error/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;
  AuthRepositoryImpl(this.dio);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return Right(const User(
        id: '1', email: 'farzad@example.com', fullName: 'Farzad Abbasi', 
        phoneNumber: '09123456789', role: UserRole.customer
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(String email, String password, String fullName, String phoneNumber, UserRole role) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return Right(User(id: '2', email: email, fullName: fullName, phoneNumber: phoneNumber, role: role));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    return const Right(null);
  }
}
