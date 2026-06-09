import '../entities/product.dart';
import '../entities/category.dart';

abstract class ProductRepository {
  Future<List<Category>> getCategories();
  Future<List<Product>> getProducts({String? category, String? query});
  Future<Product> getProductDetails(String productId);
}
