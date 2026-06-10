import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../marketplace/presentation/bloc/product_bloc.dart';
import '../../../marketplace/presentation/bloc/product_event.dart';
import '../../../marketplace/presentation/bloc/product_state.dart';
import '../../../marketplace/presentation/bloc/rental_bloc.dart';
import '../../../rental/presentation/pages/rental_booking_page.dart';
import '../../../../core/di/service_locator.dart';
import '../../../marketplace/domain/entities/product.dart';

class RentalPage extends StatefulWidget {
  const RentalPage({super.key});

  @override
  State<RentalPage> createState() => _RentalPageState();
}

class _RentalPageState extends State<RentalPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _activeCategoryFilter;
  String _searchQuery = '';

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

  String _getCategoryFa(String name) {
    switch (name.toLowerCase()) {
      case 'industrial':
        return 'ادوات صنعتی و کارگاهی';
      case 'agriculture':
        return 'ماشین‌آلات سنگین کشاورزی';
      default:
        return name;
    }
  }

  String _getCategoryEmoji(String name) {
    switch (name.toLowerCase()) {
      case 'industrial':
        return '⚙️';
      case 'agriculture':
        return '🚜';
      default:
        return '🏗️';
    }
  }

  String _getMachineryEmoji(String name) {
    if (name.contains('میکسر')) return '⚙️';
    if (name.contains('تراکتور')) return '🚜';
    return '⚡';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('اجاره ماشین‌آلات صنعتی و کشاورزی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        centerTitle: true,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            final rentalProducts = state.products.where((p) => p.isRental).toList();
            final rentalCategories = state.categories
                .where((c) => c.name == 'Industrial' || c.name == 'Agriculture')
                .toList();

            // Filter by search query
            List<Product> searchedRentals = rentalProducts;
            if (_searchQuery.isNotEmpty) {
              searchedRentals = searchedRentals.where((p) {
                return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    p.description.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();
            }

            // Mode 1: Detailed Category Grid (when category is selected OR searching is active)
            if (_activeCategoryFilter != null || _searchQuery.isNotEmpty) {
              final activeCat = _activeCategoryFilter;
              final filteredGridProducts = activeCat != null 
                  ? searchedRentals.where((p) => p.category.toLowerCase() == activeCat.toLowerCase()).toList()
                  : searchedRentals;

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
                              return _buildMachineryCard(theme, filteredGridProducts[index]);
                            },
                          ),
                  ),
                ],
              );
            }

            // Mode 2: Gorgeous Homepage with Horizontal Lists (Digikala Style for Heavy Machinery!)
            return Column(
              children: [
                _buildSearchField(theme),
                
                // Quick categories chips row
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: rentalCategories.length,
                    itemBuilder: (context, index) {
                      final category = rentalCategories[index];
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
                      // Render horizontal list section for each category dynamically!
                      ...rentalCategories.map((category) {
                        final categoryProducts = searchedRentals
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
          return const Center(child: Text('در حال آماده‌سازی مرکز اجاره...'));
        },
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'جستجوی لودر، تراکتور، میکسر بتن...',
            prefixIcon: const Icon(Icons.search_outlined),
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
    if (activeCat != null) {
      label = 'دسته: ${_getCategoryFa(activeCat)}';
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
              Text(
                '$catFaName $catEmoji',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13.5),
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
                return _buildSeeMoreCard(theme, category.name, catFaName);
              }
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: _buildMachineryCard(theme, categoryProducts[index]),
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
                style: const TextStyle(fontSize: 8.5, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachineryCard(ThemeData theme, Product item) {
    final formattedPrice = item.rentalPricePerDay
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => sl<RentalBloc>(),
                child: RentalBookingPage(product: item),
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.15),
                    child: Center(
                      child: Text(
                        _getMachineryEmoji(item.name),
                        style: const TextStyle(fontSize: 44),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'اجاره‌ای',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$formattedPrice ت / روز',
                    style: TextStyle(
                      color: theme.colorScheme.primary, 
                      fontWeight: FontWeight.bold,
                      fontSize: 10.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
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
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_photography_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('ماشین‌آلاتی یافت نشد!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          const Text('لطفا عبارت دیگری را جستجو کنید.', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
