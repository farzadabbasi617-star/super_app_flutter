import 'package:flutter/material.dart';
import 'package:super_app_flutter/core/utils/monetization_manager.dart';
import 'package:super_app_flutter/features/map/presentation/pages/shop_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _monetization = MonetizationManager();
  bool _isSellerPortalExpanded = false;

  // Mock initial seller portal orders list
  final List<Map<String, dynamic>> _receivedOrders = [
    {
      'customer': 'امیرعلی کریمی',
      'product': 'گوشی آیفون ۱۵ پرو تیتانیوم',
      'price': '۶۰,۰۰۰,۰۰۰ تومان',
      'status': 'در انتظار ارسال 🚚',
      'date': 'امروز - ۱۰:۴۵',
    },
    {
      'customer': 'سارا مهدوی',
      'product': 'کابل شارژر Fast تایپ سی',
      'price': '۱۵۰,۰۰۰ تومان',
      'status': 'تحویل داده شده ✅',
      'date': 'دیروز - ۱۸:۳۰',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'پروفایل کاربری و مدیریت مالی',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<void>(
        stream: _monetization.onStateChanged,
        builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // 1. User Info Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: const Text('👤', style: TextStyle(fontSize: 48)),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'فرزاد عباسی (غرفه‌دار و کارفرمای ارشد)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'farzadabbasi@superapp.ir',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Digital Wallet Card
                _buildWalletCard(theme),

                const SizedBox(height: 24),

                // 3. Seller / Merchant Portal (پنل مدیریت غرفه‌داران و کسب‌وکار) - NEW!
                _buildSellerPortalSection(theme),

                const SizedBox(height: 24),

                // 4. SaaS Subscription Plan Selector
                _buildSubscriptionSection(theme),

                const SizedBox(height: 24),

                // 5. Expert Bidding Coins Section
                _buildExpertCoinsSection(theme),

                const SizedBox(height: 24),

                // 6. Recent Transactions Title & List
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'تراکنش‌های اخیر و جریان‌های درآمدی',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTransactionsList(theme),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWalletCard(ThemeData theme) {
    final formattedBalance =
        _monetization.walletBalance.toStringAsFixed(0).replaceAllMapped(
              RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
              (Match m) => "${m[1]},",
            );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'موجودی کیف پول دیجیتال 💳',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                '$formattedBalance ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const Text(
                'تومان',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'شارژ کیف پول',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _showDepositDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Expanded Business Owner Portal Widget - NEW!
  Widget _buildSellerPortalSection(ThemeData theme) {
    final customBoothsCount = ShopDetailPage.customCreatedShops.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Expand icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  _isSellerPortalExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.orange.shade800,
                ),
                onPressed: () {
                  setState(() {
                    _isSellerPortalExpanded = !_isSellerPortalExpanded;
                  });
                },
              ),
              const Row(
                children: [
                  Text(
                    'پنل مدیریت غرفه و فروشندگان 🏪',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'شما دارای $customBoothsCount غرفه فعال روی نقشه هستید. جهت مدیریت سفارشات و محصولات روی فلش بزنید.',
            style: const TextStyle(fontSize: 10.5, color: Colors.grey),
            textAlign: TextAlign.right,
          ),

          if (_isSellerPortalExpanded) ...[
            const Divider(height: 24),

            // A. Earnings Analytics Bar Chart (Simulated)
            const Text(
              '📈 گزارش عملکرد و تحلیل درآمد غرفه',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مجموع فروش غرفه شما:',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                  Text(
                    '۶۰,۱۵۰,۰۰۰ تومان',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // B. Received Orders List
            const Text(
              '📦 سفارشات دریافتی اخیر مشتریان',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _receivedOrders.length,
              itemBuilder: (context, index) {
                final order = _receivedOrders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'خریدار: ${order['customer']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            order['date'],
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'کالا: ${order['product']}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            order['price'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: order['status'].contains('انتظار')
                              ? Colors.blue.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order['status'],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: order['status'].contains('انتظار')
                                ? Colors.blue.shade900
                                : Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // C. Prices and Products Manager
            const Text(
              '🏷️ ویرایش سریع قیمت محصولات غرفه‌های شما',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
            ),
            const SizedBox(height: 8),
            if (ShopDetailPage.customCreatedShops.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'هنوز غرفه‌ای روی مپ ایجاد نکرده‌اید! ابتدا از تب نقشه غرفه بسازید.',
                    style: TextStyle(color: Colors.grey, fontSize: 10.5),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...ShopDetailPage.customCreatedShops.map((booth) {
                final List<dynamic> products = booth['products'] ?? [];
                return ExpansionTile(
                  title: Text(
                    booth['name'],
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: products.map((product) {
                    return ListTile(
                      dense: true,
                      leading: Text(
                        product.icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontSize: 11),
                      ),
                      subtitle: Text(
                        product.price,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10.5,
                        ),
                      ),
                      trailing: TextButton(
                        child: const Text(
                          'ویرایش قیمت',
                          style: TextStyle(fontSize: 10),
                        ),
                        onPressed: () =>
                            _showEditPriceDialog(booth['id'], product),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
          ],
        ],
      ),
    );
  }

  // Edit product price dialog
  void _showEditPriceDialog(String boothId, dynamic product) {
    final priceController = TextEditingController(text: product.price);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'ویرایش قیمت محصول غرفه',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.right,
          ),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محصول: ${product.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'قیمت جدید کالا (همراه با تومان)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newPrice = priceController.text.trim();
                if (newPrice.isEmpty) return;

                setState(() {
                  // Actually mutate the static custom Booths product price!
                  final booth = ShopDetailPage.customCreatedShops.firstWhere(
                    (element) => element['id'] == boothId,
                  );
                  final List<dynamic> productsList = booth['products'];
                  final prodIndex = productsList.indexWhere(
                    (element) => element.name == product.name,
                  );
                  if (prodIndex > -1) {
                    // Update price
                    productsList[prodIndex] = BoothProduct(
                      name: product.name,
                      price: newPrice,
                      icon: product.icon,
                      description: product.description,
                    );
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🎉 قیمت کالا با موفقیت ویرایش شد و در ویترین غرفه فعال گردید!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('ذخیره قیمت'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubscriptionSection(ThemeData theme) {
    final activeSub = _monetization.activeSubscription;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: activeSub == 'Gold'
                      ? Colors.amber.shade100
                      : (activeSub == 'Silver'
                          ? Colors.blue.shade50
                          : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activeSub == 'Gold'
                      ? '👑 اشتراک طلایی فعال'
                      : (activeSub == 'Silver'
                          ? '🥈 اشتراک نقره‌ای فعال'
                          : '🥉 اشتراک برنزی (رایگان)'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: activeSub == 'Gold'
                        ? Colors.amber.shade900
                        : (activeSub == 'Silver'
                            ? Colors.blue.shade900
                            : Colors.grey.shade700),
                  ),
                ),
              ),
              const Text(
                'حق اشتراک غرفه‌داری (SaaS)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'با ارتقای غرفه خود به سطح طلایی، پین شما طلایی و پالس‌زن شده و در سرچ اولویت‌دهی می‌شود.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (activeSub != 'Gold')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _confirmSubscriptionUpgrade('Gold', 600000),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'خرید اشتراک طلایی (۶۰۰هزار ت)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (activeSub != 'Gold' && activeSub != 'Silver') ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _confirmSubscriptionUpgrade('Silver', 300000),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'خرید اشتراک نقره‌ای (۳۰۰هزار ت)',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
              if (activeSub == 'Gold')
                const Expanded(
                  child: Center(
                    child: Text(
                      '✨ شما دارای بالاترین سطح اشتراک غرفه‌داری هستید ✨',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCoinsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    ' سکه فعال',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    ' ${_monetization.biddingCoins} ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Text('🪙', style: TextStyle(fontSize: 16)),
                ],
              ),
              const Text(
                'سکه‌های ارسال پیشنهاد متخصصین',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'هر متخصص برای ارسال قیمت پیشنهادی روی سفارش‌های اعزام مشتریان، ۱ سکه مصرف می‌کند.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.stars_outlined, size: 16),
              label: const Text(
                'خرید بسته ۵۰ تایی سکه (۱۰۰,۰۰۰ تومان)',
                style: TextStyle(fontSize: 11.5),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () => _confirmBuyCoins(50, 100000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(ThemeData theme) {
    final list = _monetization.transactions;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        itemBuilder: (context, index) {
          final tx = list[index];
          final formattedAmount =
              tx['amount'].toStringAsFixed(0).replaceAllMapped(
                    RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
                    (Match m) => "${m[1]},",
                  );

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer.withOpacity(
                0.2,
              ),
              child: Text(tx['icon'], style: const TextStyle(fontSize: 18)),
            ),
            title: Text(
              tx['title'],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            subtitle: Text(
              tx['date'],
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.right,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  tx['isIncome'] ? '+$formattedAmount ' : '-$formattedAmount ',
                  style: TextStyle(
                    color: tx['isIncome'] ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  'تومان',
                  style: TextStyle(
                    color: tx['isIncome'] ? Colors.green : Colors.red,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDepositDialog() {
    final amountController = TextEditingController(text: '۲۰۰۰۰۰');
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'افزایش اعتبار کیف پول',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.right,
          ),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مبلغ مورد نیاز شارژ را به تومان وارد کنید:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: 'تومان',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لطفا مبلغ معتبری وارد کنید!'),
                    ),
                  );
                  return;
                }
                _monetization.depositWallet(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🎉 پرداخت شبیه‌سازی شد و کیف پول با موفقیت شارژ گردید!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('تایید و پرداخت آنلاین'),
            ),
          ],
        );
      },
    );
  }

  void _confirmSubscriptionUpgrade(String tier, double price) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'تایید ارتقای اشتراک $tier',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.right,
          ),
          content: Text(
            'آیا مایل هستید اشتراک غرفه‌داری خود را با پرداخت ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} تومان از محل موجودی کیف پول به سطح $tier ارتقا دهید؟',
            style: const TextStyle(fontSize: 12.5),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                final success = _monetization.buySubscription(tier, price);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '👑 اشتراک غرفه‌داری شما به سطح فوق‌پیشرفته $tier ارتقا یافت!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '❌ موجودی کیف پول شما برای این خرید کافی نیست. ابتدا موجودی خود را افزایش دهید!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('تایید ارتقا'),
            ),
          ],
        );
      },
    );
  }

  void _confirmBuyCoins(int count, double price) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'تایید خرید سکه پیشنهاد قیمت',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.right,
          ),
          content: Text(
            'آیا مایل هستید بسته $count عددی سکه ارسال پیشنهاد متخصص را با پرداخت ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} تومان از موجودی کیف پول تهیه کنید؟',
            style: const TextStyle(fontSize: 12.5),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                final success = _monetization.buyCoins(count, price);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🪙 بسته $count تایی سکه پیشنهاد به کیف پول متخصص شما اضافه شد!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '❌ موجودی کافی نیست. لطفاً ابتدا کیف پول خود را شارژ کنید!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('تایید خرید'),
            ),
          ],
        );
      },
    );
  }
}
