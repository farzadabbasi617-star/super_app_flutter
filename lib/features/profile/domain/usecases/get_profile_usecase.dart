import 'package:dartz/dartz.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import 'package:super_app_flutter/core/error/failures.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> execute() async {
    return await repository.getProfile();
  }
}
