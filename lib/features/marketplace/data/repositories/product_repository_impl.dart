import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      const Category(id: 'c1', name: 'Electronics', icon: '📱'),
      const Category(id: 'c2', name: 'Home', icon: '🏠'),
      const Category(id: 'c3', name: 'Fashion', icon: '👗'),
      const Category(id: 'c4', name: 'Books', icon: '📚'),
      const Category(id: 'c5', name: 'Tools', icon: '🛠️'),
      const Category(id: 'c6', name: 'Industrial', icon: '⚙️'),
      const Category(id: 'c7', name: 'Agriculture', icon: '🚜'),
    ];
  }

  @override
  Future<List<Product>> getProducts({String? category, String? query}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final allProducts = [
      // 1. Electronics
      const Product(
        id: 'p_elec_1', 
        name: 'گوشی آیفون ۱۵ پرو تیتانیوم', 
        description: 'آخرین پرچمدار اپل با بدنه تیتانیومی و تراشه A17 Pro', 
        price: 60000000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=150', 
        category: 'Electronics'
      ),
      const Product(
        id: 'p_elec_2', 
        name: 'هدفون بی‌سیم پرو مکس', 
        description: 'هدفون ارگونومیک با نویز کنسلینگ فعال و بیس عمیق شگفت‌انگیز', 
        price: 12000000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=150', 
        category: 'Electronics'
      ),
      const Product(
        id: 'p_elec_3', 
        name: 'ساعت هوشمند الترا ۲', 
        description: 'ساعت مقاوم ورزشی با صفحه همیشه روشن و سنسور اکسیژن خون', 
        price: 18000000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=150', 
        category: 'Electronics'
      ),

      // 2. Home
      const Product(
        id: 'p_home_1', 
        name: 'سرخ‌کن بدون روغن فیلیپس XL', 
        description: 'سرخ‌کن سایز بزرگ فیلیپس برای آشپزی رژیمی و سالم آسان', 
        price: 4500000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1588854337236-6889d631faa8?w=150', 
        category: 'Home'
      ),
      const Product(
        id: 'p_home_2', 
        name: 'اسپرسوساز اتوماتیک دلونگی', 
        description: 'سیستم آماده‌سازی اسپرسو و کاپوچینو با فوم شیر غلیظ اتوماتیک', 
        price: 14000000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1517256064527-09c53b2d0c6b?w=150', 
        category: 'Home'
      ),
      const Product(
        id: 'p_home_3', 
        name: 'جاروبرقی رباتیک شیائومی', 
        description: 'جاروی هوشمند با قابلیت تی‌کشی چرخشی و نقشه‌برداری لیزری خانه', 
        price: 19500000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=150', 
        category: 'Home'
      ),

      // 3. Fashion
      const Product(
        id: 'p_fash_1', 
        name: 'کفش چرم مردانه تبریز', 
        description: 'کفش چرم طبیعی صد در صد دست‌دوز تبریز با کفی طبی و نرم', 
        price: 1800000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=150', 
        category: 'Fashion'
      ),
      const Product(
        id: 'p_fash_2', 
        name: 'ساعت کلاسیک عقربه‌ای هابلوت', 
        description: 'ساعت شکیل شیشه‌ای ضد خش با بند چرمی مرغوب ضد حساسیت', 
        price: 3200000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=150', 
        category: 'Fashion'
      ),
      const Product(
        id: 'p_fash_3', 
        name: 'کت تک اسپرت مردانه سرمه‌ای', 
        description: 'کت تک شیک یقه انگلیسی دوخته شده با پارچه فاستونی درجه یک', 
        price: 2500000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=150', 
        category: 'Fashion'
      ),

      // 4. Books
      const Product(
        id: 'p_book_1', 
        name: 'کتاب آموزش برنامه نویسی پایتون', 
        description: 'کتاب مرجع یادگیری پایتون از صفر تا صد همراه با پروژه‌های کاربردی', 
        price: 250000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=150', 
        category: 'Books'
      ),
      const Product(
        id: 'p_book_2', 
        name: 'رمان صد سال تنهایی گابریل مارکز', 
        description: 'رمان جاودانه صد سال تنهایی ترجمه بدون سانسور و با کیفیت نفیس', 
        price: 120000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=150', 
        category: 'Books'
      ),
      const Product(
        id: 'p_book_3', 
        name: 'کتاب اثر مرکب دارن هاردی', 
        description: 'کتاب موفقیت و روانشناسی اثر مرکب با جلد گالینگور نفیس هدیه', 
        price: 95000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1495640388908-05fa85288e61?w=150', 
        category: 'Books'
      ),

      // 5. Tools
      const Product(
        id: 'p_tool_1', 
        name: 'جعبه ابزار چمدانی ۸۵ پارچه رونیکس', 
        description: 'کامل‌ترین جعبه ابزار چمدانی شامل آچارهای کروم وانادیوم مستحکم رونیکس', 
        price: 2400000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1581147036324-c17ac41dfa6c?w=150', 
        category: 'Tools'
      ),
      const Product(
        id: 'p_tool_2', 
        name: 'دریل شارژی دوکاره رونیکس', 
        description: 'دریل پیچ‌گوشتی شارژی با دو باتری لیتیومی قوی و کیف حمل ضربه‌گیر', 
        price: 1950000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=150', 
        category: 'Tools'
      ),
      const Product(
        id: 'p_tool_3', 
        name: 'تراز لیزری ۳۶۰ درجه خودتراز', 
        description: 'تراز لیزری ۳۶۰ درجه سه خط با نور سبز پرقدرت برد بالا', 
        price: 1600000.0, 
        imageUrl: 'https://images.unsplash.com/photo-1534224039826-c7a0eda0e6b3?w=150', 
        category: 'Tools'
      ),

      // 6. Rental Machinery (Industrial & Agriculture)
      const Product(
        id: 'p_rent_1',
        name: 'میکسر بتن دنده‌ای بتونیر صنعتی',
        description: 'میکسر بتن پرقدرت ۲۵۰ لیتری صنعتی جهت پروژه‌های بتن‌ریزی ساختمان',
        price: 15000000.0,
        imageUrl: 'https://images.unsplash.com/photo-1581147036324-c17ac41dfa6c?w=150',
        category: 'Industrial',
        isRental: true,
        rentalPricePerDay: 3000000.0,
      ),
      const Product(
        id: 'p_rent_2',
        name: 'تراکتور پرقدرت کشاورزی ITM 399',
        description: 'تراکتور جفت دیفرانسیل سنگین کشاورزی آماده به کار با ادوات کامل',
        price: 250000000.0,
        imageUrl: 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=150',
        category: 'Agriculture',
        isRental: true,
        rentalPricePerDay: 8000000.0,
      ),
      const Product(
        id: 'p_rent_3',
        name: 'ژنراتور دیزلی برق اضطراری ۵۰KVA',
        description: 'ژنراتور برق سایلنت کانوپی‌دار مناسب کارگاه‌های عمرانی و صنعتی سنگین',
        price: 95000000.0,
        imageUrl: 'https://images.unsplash.com/photo-1534224039826-c7a0eda0e6b3?w=150',
        category: 'Industrial',
        isRental: true,
        rentalPricePerDay: 4000000.0,
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
      id: 'p_elec_1', 
      name: 'گوشی آیفون ۱۵ پرو تیتانیوم', 
      description: 'آخرین پرچمدار اپل با بدنه تیتانیومی و تراشه A17 Pro', 
      price: 60000000.0, 
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=150', 
      category: 'Electronics'
    );
  }
}
