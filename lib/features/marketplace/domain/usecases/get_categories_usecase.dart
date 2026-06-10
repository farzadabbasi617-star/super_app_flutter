import 'package:dartz/dartz.dart';
import '../entities/category.dart';
import '../repositories/product_repository.dart';
import '../../../../core/error/failures.dart';

class GetCategoriesUseCase {
  final ProductRepository repository;
  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<Category>>> execute() async {
    try {
      final categories = await repository.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
