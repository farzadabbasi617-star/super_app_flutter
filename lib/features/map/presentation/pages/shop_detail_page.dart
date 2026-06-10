import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';

// Helper model to load custom products for each shop's virtual booth
class BoothProduct {
  final String name;
  final String price; // converted to Tomans
  final String icon;
  final String description;

  const BoothProduct({required this.name, required this.price, required this.icon, required this.description});
}

// Review Model
class UserReview {
  final String userName;
  final double rating;
  final String comment;
  final String? sharedProductImageUrl;
  final DateTime date;

  const UserReview({
    required this.userName,
    required this.rating,
    required this.comment,
    this.sharedProductImageUrl,
    required this.date,
  });
}

class ShopDetailPage extends StatefulWidget {
  final String shopId;

  const ShopDetailPage({super.key, required this.shopId});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  final _commentController = TextEditingController();
  double _userRating = 5.0;
  String? _selectedImage; // Simulate a shared photo
  final List<UserReview> _customReviews = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Load custom data based on the selected Shop ID (Prices converted to Tomans!)
  Map<String, dynamic> _getShopData() {
    switch (widget.shopId) {
      case 's1':
        return {
          'name': 'مرکز فنی تک هاب',
          'category': 'الکترونیک و تعمیرات گجت',
          'rating': 4.8,
          'reviews': 124,
          'address': 'تهران، خیابان ولیعصر، نرسیده به میدان ونک، پلاک ۴',
          'phone': '+۹۸ ۲۱ ۸۸۷۷ ۶۶۵۵',
          'hours': '۰۹:۰۰ الی ۲۲:۰۰',
          'about': 'بزرگترین مرکز تخصصی فروش گجت و تعمیرات سخت‌افزاری انواع موبایل، تبلت و لپ‌تاپ در تهران با گارانتی معتبر قطعات و تحویل فوری.',
          'avatar': '📱',
          'products': const [
            BoothProduct(name: 'گوشی iPhone 15 Pro', price: '۶۰,۰۰۰,۰۰۰ تومان', icon: '📱', description: 'آخرین پرچمدار اپل با بدنه تیتانیوم'),
            BoothProduct(name: 'شارژر بی‌سیم Fast', price: '۲,۵۰۰,۰۰۰ تومان', icon: '🔌', description: 'شارژ سریع مغناطیسی ۱۵ وات مغناطیسی'),
            BoothProduct(name: 'پایه نگهدارنده تلسکوپی', price: '۱,۲۰۰,۰۰۰ تومان', icon: '📐', description: 'پایه تمام فلزی رومیزی با زاویه قابل تنظیم'),
            BoothProduct(name: 'پاوربانک ۲۰,۰۰0 میلی‌آمپر', price: '۳,۵۰۰,۰۰۰ تومان', icon: '🔋', description: 'پاوربانک با ظرفیت بالا و دو پورت خروجی سریع'),
          ],
          'defaultReviews': [
            UserReview(userName: 'امیرعلی رضایی', rating: 5.0, comment: 'عالی بود! گوشی آیفونی که خریدم را با گارانتی رسمی اصلی و بهترین قیمت تحویل دادند. گلس هدیه هم چسباندند.', sharedProductImageUrl: 'uploads/Screenshot_2026-06-09-20-57-38-358_com.android.chrome.jpg', date: DateTime.now().subtract(const Duration(days: 2))),
            const UserReview(userName: 'سارا کریمی', rating: 4.5, comment: 'پایه تلسکوپی را سفارش دادم، کیفیت ساختش عالیه و فلز سنگینی داره. برخورد پرسنل هم خیلی خوب بود.', date: DateTime.now().subtract(const Duration(days: 5))),
          ]
        };
      case 's2':
        return {
          'name': 'گلستان گرین گاردن',
          'category': 'پرورش گل و گیاه زینتی',
          'rating': 4.5,
          'reviews': 89,
          'address': 'تهران، خیابان نیاوران، نرسیده به کاخ، پلاک ۱',
          'phone': '+۹۸ ۲۱ ۲۲۳۳ ۴۴۵۵',
          'hours': '۰۸:۰۰ الی ۲۰:۰۰',
          'about': 'عرضه‌کننده انواع گیاهان آپارتمانی خاص، درختچه‌های بن‌سای، خاک ارگانیک و خدمات تخصصی طراحی دکوراسیون و محوطه‌سازی فضای سبز و تراس گاردن.',
          'avatar': '🌱',
          'products': const [
            BoothProduct(name: 'درختچه بن‌سای جینسینگ', price: '۵,۰۰۰,۰۰۰ تومان', icon: '🌳', description: 'بن‌سای جینسینگ مینیاتوری با گلدان سرامیکی'),
            BoothProduct(name: 'گلدان فیلودندرون برگ انجیری', price: '۲,۰۰۰,۰۰۰ تومان', icon: '🌿', description: 'برگ انجیری پهن برگ آپارتمانی شاداب'),
            BoothProduct(name: 'پک خاک ارگانیک غنی‌شده', price: '۵۰۰,۰۰۰ تومان', icon: '🟫', description: 'خاک غنی با ورمی‌کمپوست مخصوص گیاهان آپارتمانی'),
            BoothProduct(name: 'کود مایع رشد سریع نیتروژن', price: '۸۰۰,۰۰۰ تومان', icon: '🧪', description: 'کود مایع جهت شادابی و تسریع در برگ‌دهی گیاه'),
          ],
          'defaultReviews': [
            const UserReview(userName: 'مهدی حسینی', rating: 5.0, comment: 'بن‌سای جینسینگی که ازشون گرفتم واقعا شادابه و به موقع فرستادند. خاکشون هم خیلی باکیفیته.', date: DateTime.now().subtract(const Duration(days: 3))),
          ]
        };
      case 's3':
        return {
          'name': 'کافه تخصصی کرنر',
          'category': 'اسپرسو بار و نوشیدنی‌های گرم',
          'rating': 4.9,
          'reviews': 210,
          'address': 'تهران، خیابان جردن، خیابان طاهری، پلاک ۲',
          'phone': '+۹۸ ۲۱ ۲۲۰۲ ۲۲۱۱',
          'hours': '۰۷:۰۰ الی ۲۳:۰۰',
          'about': 'کافه دنج و آرام با منوی غنی از انواع قهوه‌های تک‌خاستگاه اسپشیالتی عربیکا، نوشیدنی‌های خنک و کرواسان‌های تازه و گرم پخت روز.',
          'avatar': '☕',
          'products': const [
            BoothProduct(name: 'آرتیسان لاته داغ', price: '۲۵۰,۰۰۰ تومان', icon: '☕', description: 'اسپرسو دوبل به همراه شیر خامه ابریشمی'),
            BoothProduct(name: 'کرواسان شکلاتی بلژیکی', price: '۱۸۰,۰۰۰ تومان', icon: '🥐', description: 'کرواسان تازه پخت روز با فیلینگ شکلات بلژیکی گرم'),
            BoothProduct(name: 'آیس لاته کارامل نمکی', price: '۲۹۰,۰۰۰ تومان', icon: '🥤', description: 'قهوه سرد با سیروپ کارامل نمکی خانگی'),
            BoothProduct(name: 'قهوه تک‌خاستگاه کلمبیا (۲۵۰گرم)', price: '۱,۰۰۰,۰۰۰ تومان', icon: '🫘', description: 'دانه‌های تازه برشته شده قهوه کلمبیا با نوت‌های کاکائو'),
          ],
          'defaultReviews': [
            const UserReview(userName: 'مریم قربانی', rating: 5.0, comment: 'طعم لاته عالی بود و کرواسانشون فوق‌العاده ترد و تازه بود. فضا هم بسیار دنج و آرامه.', date: DateTime.now().subtract(const Duration(days: 1))),
          ]
        };
      default:
        return {
          'name': 'کسب‌و‌کار بومی',
          'category': 'فروشگاه محلی',
          'rating': 4.0,
          'reviews': 10,
          'address': 'تهران، ایران',
          'phone': 'N/A',
          'hours': '۰۹:۰۰ - ۲۱:۰۰',
          'about': 'یک غرفه بومی و معتبر ثبت شده در موقعیت یابی سوپراپلیکیشن.',
          'avatar': '🏪',
          'products': const <BoothProduct>[],
          'defaultReviews': <UserReview>[]
        };
    }
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا متن نظر خود را وارد کنید.')),
      );
      return;
    }

    setState(() {
      _customReviews.insert(0, UserReview(
        userName: 'شما (کاربر مهمان)',
        rating: _userRating,
        comment: text,
        sharedProductImageUrl: _selectedImage,
        date: DateTime.now(),
      ));
      _commentController.clear();
      _selectedImage = null;
      _userRating = 5.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تجربه خرید و نظر شما با موفقیت در غرفه ثبت شد!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shop = _getShopData();
    final List<BoothProduct> products = shop['products'];
    final List<UserReview> defaultReviews = shop['defaultReviews'];

    // Combine default and custom user reviews
    final allReviews = [..._customReviews, ...defaultReviews];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Expanded visual banner for the Virtual Booth
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'غرفه ${shop['name']}', 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        shop['avatar'],
                        style: const TextStyle(fontSize: 100),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Virtual Booth Title Card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop['name'], 
                              style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              shop['category'],
                              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text('${shop['rating']}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('${shop['reviews']} نظر', style: TextStyle(fontSize: 10, color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Info Tiles
                  _buildInfoTile(theme, Icons.location_on_outlined, 'آدرس فیزیکی غرفه', shop['address']),
                  _buildInfoTile(theme, Icons.phone_outlined, 'شماره تماس مستقیم', shop['phone']),
                  _buildInfoTile(theme, Icons.access_time_outlined, 'ساعت کاری غرفه', shop['hours']),
                  const Divider(height: 32),
                  
                  // About Booth
                  Text('درباره این غرفه', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    shop['about'],
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7), height: 1.6),
                  ),
                  const Divider(height: 40),

                  // Featured Products inside this shop's Booth
                  if (products.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ویترین و گالری محصولات غرفه', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('(${products.length} کالا)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _showBoothPurchaseDialog(context, product, shop['name']),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                                    width: double.infinity,
                                    child: Center(
                                      child: Text(
                                        product.icon,
                                        style: const TextStyle(fontSize: 48),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name, 
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.price, 
                                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        product.description,
                                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 9.5),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 40),
                  ],

                  // CUSTOMER REVIEWS & PHOTO SHARING SECTION (بخش نظرات و اشتراک تصاویر خریداران)
                  Text('تجربیات خریداران و نظرات غرفه', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),

                  // Submit Review Form
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ثبت تجربه خرید و نظر جدید', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('امتیاز شما:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              Row(
                                children: List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _userRating = index + 1.0;
                                      });
                                    },
                                    child: Icon(
                                      Icons.star,
                                      color: index < _userRating ? Colors.amber : Colors.grey.shade400,
                                      size: 24,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _commentController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'تجربه خود را از خرید محصول یا برخورد غرفه‌دار بنویسید...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Image selection simulation row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _selectedImage == null
                                  ? OutlinedButton.icon(
                                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                                      label: const Text('اشتراک تصویر محصول خریده‌شده', style: TextStyle(fontSize: 11.5)),
                                      onPressed: () {
                                        setState(() {
                                          _selectedImage = 'uploads/Screenshot_2026-06-09-20-57-38-358_com.android.chrome.jpg'; // Load real workspace file!
                                        });
                                      },
                                    )
                                  : Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.asset(
                                            _selectedImage!,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 48,
                                              height: 48,
                                              color: Colors.grey,
                                              child: const Icon(Icons.image),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          onPressed: () => setState(() => _selectedImage = null),
                                          child: const Text('حذف عکس', style: TextStyle(color: Colors.red, fontSize: 11.5)),
                                        ),
                                      ],
                                    ),
                              ElevatedButton(
                                onPressed: _addComment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('ثبت نظر', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reviews List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allReviews.length,
                    itemBuilder: (context, index) {
                      final review = allReviews[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        Icons.star,
                                        color: starIndex < review.rating ? Colors.amber : Colors.grey.shade300,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                review.comment,
                                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8), fontSize: 12.5, height: 1.5),
                              ),
                              
                              // Display shared product photo if present!
                              if (review.sharedProductImageUrl != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      review.sharedProductImageUrl!,
                                      maxHeight: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 100,
                                        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                                        child: Center(
                                          child: Icon(Icons.image, color: theme.colorScheme.primary.withOpacity(0.5)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
        ),
        child: AppButton(
          text: 'شروع گفتگوی زنده با غرفه‌دار',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('در حال اتصال به چت زنده غرفه‌دار (${shop['name']})...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          type: AppButtonType.primary,
          icon: Icons.chat_bubble_outline,
        ),
      ),
    );
  }

  Widget _buildInfoTile(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
