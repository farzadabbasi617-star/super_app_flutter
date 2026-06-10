import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const Category(id: 'c1', name: 'Electronics', icon: '📱'),
      const Category(id: 'c2', name: 'Home', icon: '🏠'),
      const Category(id: 'c3', name: 'Fashion', icon: '👗'),
      const Category(id: 'c4', name: 'Books', icon: '📚'),
      const Category(id: 'c5', name: 'Tools', icon: '🛠️'),
    ];
  }

  @override
  Future<List<Product>> getProducts({String? category, String? query}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allProducts = [
      const Product(
        id: 'p1', 
        name: 'گوشی آیفون ۱۵ پرو تیتانیوم', 
        description: 'آخرین پرچمدار اپل با بدنه تیتانیومی و دوربین ۴۸ مگاپیکسلی خارق‌العاده', 
        price: 60000000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=150', 
        category: 'Electronics'
      ),
      const Product(
        id: 'p2', 
        name: 'سرخ‌کن بدون روغن فیلیپس', 
        description: 'سرخ‌کن سایز بزرگ فیلیپس برای آشپزی رژیمی و سالم آسان', 
        price: 4500000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=150', 
        category: 'Home'
      ),
      const Product(
        id: 'p3', 
        name: 'کفش چرم مردانه تبریز', 
        description: 'کفش چرم طبیعی صد در صد دست‌دوز تبریز با کفی طبی و نرم', 
        price: 1800000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=150', 
        category: 'Fashion'
      ),
      const Product(
        id: 'p4', 
        name: 'کتاب آموزش برنامه نویسی پایتون', 
        description: 'کتاب مرجع یادگیری پایتون از صفر تا صد همراه با پروژه‌های کاربردی', 
        price: 250000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=150', 
        category: 'Books'
      ),
      const Product(
        id: 'p5', 
        name: 'جعبه ابزار چمدانی ۸۵ پارچه رونیکس', 
        description: 'کامل‌ترین جعبه ابزار چمدانی شامل آچارهای کروم وانادیوم مستحکم رونیکس', 
        price: 2400000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?w=150', 
        category: 'Tools'
      ),
    ];

    List<Product> results = allProducts;
    if (category != null) {
      results = results.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
    }
    if (query != null && query.isNotEmpty) {
      results = results.where((p) => p.name.toLowerCase().contains(query.toLowerCase()) || p.description.toLowerCase().contains(query.toLowerCase())).toList();
    }
    return results;
  }

  @override
  Future<Product> getProductDetails(String productId) async {
    return const Product(
      id: 'p1', 
      name: 'گوشی آیفون ۱۵ پرو تیتانیوم', 
      description: 'آخرین پرچمدار اپل با بدنه تیتانیومی و دوربین ۴۸ مگاپیکسلی خارق‌العاده', 
      price: 60000000.0, 
      imageUrl: 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=150', 
      category: 'Electronics'
    );
  }
}
