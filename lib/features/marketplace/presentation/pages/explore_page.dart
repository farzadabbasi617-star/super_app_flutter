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
  
  // Local state for shopping cart and favorites
  final Map<Product, int> _cart = {};
  final Set<String> _favoritedIds = {};
  
  // Active category filter (null means show homapage with horizontal scrollable lists)
  String? _activeCategoryFilter;
  bool _showOnlyFavorites = false;

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

  // Convert English category names to Persian
  String _getCategoryFa(String name) {
    switch (name.toLowerCase()) {
      case 'electronics':
        return 'الکترونیک و دیجیتال';
      case 'home':
        return 'لوازم خانگی';
      case 'fashion':
        return 'پوشاک و مد';
      case 'books':
        return 'کتاب و تحریر';
      case 'tools':
        return 'ابزارآلات صنعتی';
      default:
        return name;
    }
  }

  String _getCategoryEmoji(String name) {
    switch (name.toLowerCase()) {
      case 'electronics':
        return '📱';
      case 'home':
        return '🏠';
      case 'fashion':
        return '👗';
      case 'books':
        return '📚';
      case 'tools':
        return '🛠️';
      default:
        return '🛍️';
    }
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

  // Calculate cart badge count
  int get _cartTotalItems {
    return _cart.values.fold(0, (sum, qty) => sum + qty);
  }

  // Calculate cart total price
  double get _cartTotalPrice {
    return _cart.entries.fold(0.0, (sum, entry) => sum + (entry.key.price * entry.value));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('بازارچه هوشمند کالا 🛍️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
            color: _showOnlyFavorites ? Colors.red : null,
          ),
          onPressed: () {
            setState(() {
              _showOnlyFavorites = !_showOnlyFavorites;
              _activeCategoryFilter = null; // Reset category filter if toggling favorites
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_showOnlyFavorites ? 'فیلتر: فقط علاقه‌مندی‌ها ❤️' : 'نمایش همه کالاها'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        actions: [
          // Shopping Cart Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: _openCartSheet,
              ),
              if (_cartTotalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_cartTotalItems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            final List<Product> purchaseProducts = state.products.where((p) => !p.isRental).toList();
            final purchaseCategories = state.categories;

            // Handle Search Query filtering
            List<Product> searchedProducts = purchaseProducts;
            if (_searchQuery.isNotEmpty) {
              searchedProducts = purchaseProducts.where((p) {
                return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    p.description.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();
            }

            // Handle Show Favorites Only
            if (_showOnlyFavorites) {
              searchedProducts = searchedProducts.where((p) => _favoritedIds.contains(p.id)).toList();
            }

            // Mode 1: Detailed Category Grid (when category is selected OR searching is active)
            if (_activeCategoryFilter != null || _searchQuery.isNotEmpty || _showOnlyFavorites) {
              final activeCat = _activeCategoryFilter;
              final filteredGridProducts = activeCat != null 
                  ? searchedProducts.where((p) => p.category.toLowerCase() == activeCat.toLowerCase()).toList()
                  : searchedProducts;

              return Column(
                children: [
                  _buildSearchField(theme),
                  _buildFilteredHeader(theme, activeCat),
                  Expanded(
                    child: filteredGridProducts.isEmpty
                        ? _buildEmptyState(theme)
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: filteredGridProducts.length,
                            itemBuilder: (context, index) {
                              return _buildProductCard(theme, filteredGridProducts[index]);
                            },
                          ),
                  ),
                ],
              );
            }

            // Mode 2: Gorgeous Homepage with Horizontal Lists per Category (Digikala Style!)
            return Column(
              children: [
                _buildSearchField(theme),
                
                // Active Categories quick chips row at top of main view
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: purchaseCategories.length,
                    itemBuilder: (context, index) {
                      final category = purchaseCategories[index];
                      final catFa = _getCategoryFa(category.name);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: Text(category.icon),
                          label: Text(catFa, style: const TextStyle(fontSize: 11)),
                          selected: false,
                          onPressed: () {
                            setState(() {
                              _activeCategoryFilter = category.name;
                            });
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    },
                  ),
                ),
                
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // Interactive Promo Banner
                      _buildPromoBanner(theme),
                      
                      // Render horizontal list section for each category dynamically!
                      ...purchaseCategories.map((category) {
                        final categoryProducts = searchedProducts
                            .where((p) => p.category.toLowerCase() == category.name.toLowerCase())
                            .toList();
                        
                        if (categoryProducts.isEmpty) return const SizedBox.shrink();
                        
                        return _buildCategoryHorizontalSection(theme, category, categoryProducts);
                      }),
                    ],
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

  String _searchQuery = '';

  Widget _buildSearchField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'جستجوی نام کالا یا صنف...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.clear), 
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.35),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFilteredHeader(ThemeData theme, String? activeCat) {
    String label = 'نتایج فیلتر شده';
    if (_showOnlyFavorites) {
      label = 'علاقه‌مندی‌های من ❤️';
    } else if (activeCat != null) {
      label = 'صنف: ${_getCategoryFa(activeCat)}';
    } else if (_searchQuery.isNotEmpty) {
      label = 'نتایج جستجوی: $_searchQuery';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('بازگشت به دسته‌ها', style: TextStyle(fontSize: 11)),
            onPressed: () {
              setState(() {
                _activeCategoryFilter = null;
                _showOnlyFavorites = false;
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'جشنواره شگفت‌انگیز سوپراپلیکیشن! 🎉',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'تخفیف‌های استثنایی بر روی کلیه صنف‌ها فقط امروز',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10),
                ),
              ],
            ),
            const Text('🔥', style: TextStyle(fontSize: 40)),
          ],
        ),
      ),
    );
  }

  // Horizontal Scrollable Category Row Widget
  Widget _buildCategoryHorizontalSection(ThemeData theme, dynamic category, List<Product> categoryProducts) {
    final catFaName = _getCategoryFa(category.name);
    final catEmoji = _getCategoryEmoji(category.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _activeCategoryFilter = category.name;
                  });
                },
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios, size: 12, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'دیدن بیشتر',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    '$catFaName $catEmoji',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Horizontally Scrollable list
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categoryProducts.length + 1,
            itemBuilder: (context, index) {
              if (index == categoryProducts.length) {
                // "See More" card at the end of the list
                return _buildSeeMoreCard(theme, category.name, catFaName);
              }
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: _buildProductCard(theme, categoryProducts[index]),
              );
            },
          ),
        ),
        const Divider(height: 24, thickness: 0.5),
      ],
    );
  }

  Widget _buildSeeMoreCard(ThemeData theme, String categoryName, String categoryFa) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeCategoryFilter = categoryName;
        });
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 12),
              const Text(
                'مشاهده همه',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                categoryFa,
                style: const TextStyle(fontSize: 9, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Individual Product Card Widget (Grid or Horizontal scroll)
  Widget _buildProductCard(ThemeData theme, Product product) {
    final formattedPrice = product.price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");
    final isFav = _favoritedIds.contains(product.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          InkWell(
            onTap: () => _showProductDetailsDialog(product),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.12),
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        _getProductEmoji(product.category),
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5), 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$formattedPrice تومان',
                        style: TextStyle(
                          color: theme.colorScheme.primary, 
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.description,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 8.5,
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
          // Heart Icon (Favorites Toggle)
          Positioned(
            top: 4,
            right: 4,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                  size: 16,
                ),
                onPressed: () {
                  setState(() {
                    if (isFav) {
                      _favoritedIds.remove(product.id);
                    } else {
                      _favoritedIds.add(product.id);
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
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
          const Text('شاید لیست علاقه‌مندی‌ها خالی باشد یا عبارتی جستجو نشده باشد.', style: TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  // Interactive Product Detail, Cart action, and Instant purchase modal!
  void _showProductDetailsDialog(Product product) {
    final theme = Theme.of(context);
    final formattedPrice = product.price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.right),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    _getProductEmoji(product.category),
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('توضیحات محصول:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Text(product.description, style: const TextStyle(fontSize: 11.5, color: Colors.black87)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('قیمت واحد:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                    Text(
                      '$formattedPrice تومان',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _cart[product] = (_cart[product] ?? 0) + 1;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('📥 محصول «${product.name}» به سبد خرید اضافه شد!'),
                    backgroundColor: Colors.blue.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('افزودن به سبد خرید'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showInstantPurchaseCheckout(product);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('خرید آنی 💳'),
            ),
          ],
        );
      },
    );
  }

  // Instant direct buy dialog
  void _showInstantPurchaseCheckout(Product product) {
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
          title: const Text('تایید خرید فوری 💳', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.right),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('آیا می‌خواهید خرید خودکار کالا «${product.name}» را نهایی کنید؟', style: const TextStyle(fontSize: 12.5)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('قیمت نهایی:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('$formattedPrice تومان', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
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
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (monetization.walletBalance >= product.price) {
                  setState(() {
                    monetization.walletBalance -= product.price;
                    monetization.addTransaction(
                      'خرید فوری کالا: ${product.name}',
                      -product.price,
                      false,
                      '🛍️',
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 خرید فوری «${product.name}» موفقیت‌آمیز بود! کیف پول کسر شد.'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ موجودی کیف پول کافی نیست! ابتدا موجودی خود را افزایش دهید.'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white),
              child: const Text('پرداخت و خرید'),
            ),
          ],
        );
      },
    );
  }

  // Open the detailed Shopping Cart bottom sheet!
  void _openCartSheet() {
    final theme = Theme.of(context);
    final monetization = MonetizationManager();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cartItems = _cart.entries.toList();
            final formattedTotal = _cartTotalPrice
                .toStringAsFixed(0)
                .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");
            final formattedWallet = monetization.walletBalance
                .toStringAsFixed(0)
                .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");

            return Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'سبد خرید شما 🛒',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (cartItems.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'سبد خرید شما خالی است! 📥',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    )
                  else ...[
                    // Scrollable List of Cart items
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final product = item.key;
                          final qty = item.value;
                          final formattedItemPrice = (product.price * qty)
                              .toStringAsFixed(0)
                              .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.2),
                              child: Text(_getProductEmoji(product.category)),
                            ),
                            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.right),
                            subtitle: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Text('$formattedItemPrice تومان', style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.red),
                                  onPressed: () {
                                    setModalState(() {
                                      setState(() {
                                        if (qty > 1) {
                                          _cart[product] = qty - 1;
                                        } else {
                                          _cart.remove(product);
                                        }
                                      });
                                    });
                                  },
                                ),
                                Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.green),
                                  onPressed: () {
                                    setModalState(() {
                                      setState(() {
                                        _cart[product] = qty + 1;
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 24),
                    
                    // Total prices rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection: TextDirection.rtl,
                      children: [
                        const Text('مجموع سبد خرید:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('$formattedTotal تومان', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection: TextDirection.rtl,
                      children: [
                        const Text('موجودی کیف پول دیجیتال:', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                        Text('$formattedWallet تومان', style: const TextStyle(fontSize: 11.5, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Purchase Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.credit_card),
                        label: const Text('تایید و پرداخت نهایی سبد خرید 💳', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          if (monetization.walletBalance >= _cartTotalPrice) {
                            setState(() {
                              monetization.walletBalance -= _cartTotalPrice;
                              monetization.addTransaction(
                                'خرید سبد کالا (${_cartTotalItems} قلم)',
                                -_cartTotalPrice,
                                false,
                                '🛒',
                              );
                              _cart.clear(); // Clear cart after success
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎉 سفارش شما با موفقیت ثبت شد و فاکتور تجاری آن صادر گردید!'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('❌ موجودی کیف پول برای خرید کل سبد کافی نیست! لطفاً حساب خود را شارژ کنید.'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
