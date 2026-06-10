import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../domain/entities/product.dart';
import '../../../../core/utils/monetization_manager.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductsRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Convert English category names to Persian for the UI chips
  String _getCategoryFa(String name) {
    switch (name.toLowerCase()) {
      case 'electronics':
        return 'الکترونیک';
      case 'home':
        return 'لوازم خانگی';
      case 'fashion':
        return 'پوشاک و مد';
      case 'books':
        return 'کتاب و تحریر';
      case 'tools':
        return 'ابزارآلات';
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('بازارچه خرید و فروش کالا', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'جستجوی کالا جهت خرید مستقیم...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) {
                  context.read<ProductBloc>().add(LoadProductsRequested(query: val));
                },
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            // Keep all purchase products
            final purchaseProducts = state.products.where((p) => !p.isRental).toList();
            final purchaseCategories = state.categories;

            return Column(
              children: [
                // Category Filter Chips Row
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: purchaseCategories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('همه کالاها'),
                            selected: state.selectedCategory == null,
                            onPressed: () => context.read<ProductBloc>().add(LoadProductsRequested()),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        );
                      }
                      final category = purchaseCategories[index - 1];
                      final catFa = _getCategoryFa(category.name);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${category.icon} $catFa'),
                          selected: state.selectedCategory == category.name,
                          onPressed: () => context.read<ProductBloc>().add(CategoryChanged(category.name)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    },
                  ),
                ),
                
                // Products Grid
                Expanded(
                  child: purchaseProducts.isEmpty
                      ? _buildEmptyState(theme)
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: purchaseProducts.length,
                          itemBuilder: (context, index) {
                            final product = purchaseProducts[index];
                            final formattedPrice = product.price
                                .toStringAsFixed(0)
                                .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => _showPurchaseDialog(context, product),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color: theme.colorScheme.primaryContainer.withOpacity(0.15),
                                        width: double.infinity,
                                        child: Center(
                                          child: Text(
                                            _getProductEmoji(product.category),
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
                                            '$formattedPrice تومان',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.primary, 
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            product.description,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                                              fontSize: 9.5,
                                            ),
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
                ),
              ],
            );
          } else if (state is ProductFailure) {
            return Center(child: Text('خطا در بارگذاری: ${state.error}'));
          }
          return const Center(child: Text('در حال آماده‌سازی مارکت‌پلیس...'));
        },
      ),
    );
  }

  String _getProductEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return '📱';
      case 'home':
        return '🍳';
      case 'fashion':
        return '👟';
      case 'books':
        return '📚';
      case 'tools':
        return '🧰';
      default:
        return '🛍️';
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('کالایی یافت نشد!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          const Text('لطفا عبارت دیگری را جستجو کنید.', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final monetization = MonetizationManager();
    final formattedPrice = product.price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تایید خرید کالا 🛒', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.right),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('آیا مایل هستید محصول «${product.name}» را خریداری کنید؟', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Text(product.description, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('قیمت نهایی محصول:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                    Text(
                      '$formattedPrice تومان',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('موجودی کیف پول شما:', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                    Text(
                      '${monetization.walletBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} تومان',
                      style: const TextStyle(fontSize: 11.5, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (monetization.walletBalance >= product.price) {
                  setState(() {
                    monetization.walletBalance -= product.price;
                    monetization.addTransaction(
                      'خرید کالا: ${product.name}',
                      -product.price,
                      false,
                      '🛍️',
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 تبریک! محصول «${product.name}» با موفقیت خریداری شد و از کیف پول شما کسر گردید!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ موجودی کیف پول شما کافی نیست! ابتدا حساب خود را در تب کیف پول شارژ کنید.'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('تایید و پرداخت آنلاین'),
            ),
          ],
        );
      },
    );
  }
}
