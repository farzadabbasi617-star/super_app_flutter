import 'package:dartz/dartz.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../core/error/failures.dart';

class GetProductsUseCase {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> execute({String? category, String? query}) async {
    try {
      final products = await repository.getProducts(category: category, query: query);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
