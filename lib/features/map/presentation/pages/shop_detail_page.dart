import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';

// Helper model to load custom products for each shop's virtual booth
class BoothProduct {
  final String name;
  final String price;
  final String icon;
  final String description;

  const BoothProduct({required this.name, required this.price, required this.icon, required this.description});
}

class ShopDetailPage extends StatelessWidget {
  final String shopId;

  const ShopDetailPage({super.key, required this.shopId});

  // Load custom data based on the selected Shop ID
  Map<String, dynamic> _getShopData() {
    switch (shopId) {
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
            BoothProduct(name: 'گوشی iPhone 15 Pro', price: '۹۹۹ دلار', icon: '📱', description: 'آخرین پرچمدار اپل با بدنه تیتانیوم'),
            BoothProduct(name: 'شارژر بی‌سیم Fast', price: '۴۵ دلار', icon: '🔌', description: 'شارژ سریع مغناطیسی ۱۵ وات مغناطیسی'),
            BoothProduct(name: 'پایه نگهدارنده تلسکوپی', price: '۲۵ دلار', icon: '📐', description: 'پایه تمام فلزی رومیزی با زاویه قابل تنظیم'),
            BoothProduct(name: 'پاوربانک ۲۰,۰۰۰ میلی‌آمپر', price: '۶۰ دلار', icon: '🔋', description: 'پاوربانک با ظرفیت بالا و دو پورت خروجی سریع'),
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
            BoothProduct(name: 'درختچه بن‌سای جینسینگ', price: '۸۵ دلار', icon: '🌳', description: 'بن‌سای جینسینگ مینیاتوری با گلدان سرامیکی'),
            BoothProduct(name: 'گلدان فیلودندرون برگ انجیری', price: '۳۵ دلار', icon: '🌿', description: 'برگ انجیری پهن برگ آپارتمانی شاداب'),
            BoothProduct(name: 'پک خاک ارگانیک غنی‌شده', price: '۱۰ دلار', icon: '🟫', description: 'خاک غنی با ورمی‌کمپوست مخصوص گیاهان آپارتمانی'),
            BoothProduct(name: 'کود مایع رشد سریع نیتروژن', price: '۱۵ دلار', icon: '🧪', description: 'کود مایع جهت شادابی و تسریع در برگ‌دهی گیاه'),
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
            BoothProduct(name: 'آرتیسان لاته داغ', price: '۴.۵ دلار', icon: '☕', description: 'اسپرسو دوبل به همراه شیر خامه ابریشمی'),
            BoothProduct(name: 'کرواسان شکلاتی بلژیکی', price: '۳.۵ دلار', icon: '🥐', description: 'کرواسان تازه پخت روز با فیلینگ شکلات بلژیکی گرم'),
            BoothProduct(name: 'آیس لاته کارامل نمکی', price: '۵ دلار', icon: '🥤', description: 'قهوه سرد با سیروپ کارامل نمکی خانگی'),
            BoothProduct(name: 'قهوه تک‌خاستگاه کلمبیا (۲۵۰گرم)', price: '۱۸ دلار', icon: '🫘', description: 'دانه‌های تازه برشته شده قهوه کلمبیا با نوت‌های کاکائو'),
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
          'products': const <BoothProduct>[]
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shop = _getShopData();
    final List<BoothProduct> products = shop['products'];

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
                        childAspectRatio: 0.75,
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
                                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        product.description,
                                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 10),
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
                  ],
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

  void _showBoothPurchaseDialog(BuildContext context, BoothProduct product, String shopName) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تایید خرید از غرفه'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('آیا تمایل به خرید "${product.name}" از غرفه "${shopName}" دارید؟', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(product.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('مبلغ کالا:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(product.price, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.colorScheme.primary)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('کالای "${product.name}" از غرفه با موفقیت خریداری شد!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('خرید مستقیم'),
            ),
          ],
        );
      },
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
