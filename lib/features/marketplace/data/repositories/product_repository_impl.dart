import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const Category(id: 'c1', name: 'Electronics', icon: '📱'),
      const Category(id: 'c2', name: 'Industrial', icon: '⚙️'),
      const Category(id: 'c3', name: 'Agriculture', icon: '🚜'),
      const Category(id: 'c4', name: 'Home', icon: '🏠'),
    ];
  }

  @override
  Future<List<Product>> getProducts({String? category, String? query}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allProducts = [
      const Product(id: 'p1', name: 'iPhone 15 Pro', description: 'Latest Apple flagship', price: 999, imageUrl: 'https://via.placeholder.com/150', category: 'Electronics'),
      const Product(id: 'p2', name: 'Concrete Mixer', description: 'Heavy duty industrial mixer', price: 5000, imageUrl: 'https://via.placeholder.com/150', category: 'Industrial', isRental: true, rentalPricePerDay: 50),
      const Product(id: 'p3', name: 'Tractor X-200', description: 'High performance agricultural tractor', price: 25000, imageUrl: 'https://via.placeholder.com/150', category: 'Agriculture', isRental: true, rentalPricePerDay: 120),
      const Product(id: 'p4', name: 'Air Fryer', description: 'Healthy cooking made easy', price: 120, imageUrl: 'https://via.placeholder.com/150', category: 'Home'),
      const Product(id: 'p5', name: 'Generator 5kW', description: 'Reliable power backup', price: 800, imageUrl: 'https://via.placeholder.com/150', category: 'Industrial', isRental: true, rentalPricePerDay: 30),
    ];

    if (category != null) {
      return allProducts.where((p) => p.category == category).toList();
    }
    if (query != null) {
      return allProducts.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    return allProducts;
  }

  @override
  Future<Product> getProductDetails(String productId) async {
    return const Product(id: 'p1', name: 'iPhone 15 Pro', description: 'Detailed description of the iPhone 15 Pro...', price: 999, imageUrl: 'https://via.placeholder.com/150', category: 'Electronics');
  }
}
