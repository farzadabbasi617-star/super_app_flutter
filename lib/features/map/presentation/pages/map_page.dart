import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../../domain/entities/shop.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = const LatLng(35.6892, 51.3890);

  // Filter States
  String _searchQuery = '';
  String? _selectedCategory;
  Shop? _selectedShop;

  final List<Map<String, String>> _categories = [
    {'name': 'Electronics', 'icon': '📱'},
    {'name': 'Plants', 'icon': '🌱'},
    {'name': 'Cafe', 'icon': '☕'},
  ];

  @override
  void initState() {
    super.initState();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapBloc>().add(LoadNearbyShopsRequested(_initialPosition));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MapLoaded) {
            // Apply filtering in real-time on client side
            final filteredShops = state.shops.where((shop) {
              final matchesCategory = _selectedCategory == null || shop.category == _selectedCategory;
              final matchesQuery = _searchQuery.isEmpty || 
                  shop.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  shop.category.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesQuery;
            }).toList();

            return Stack(
              children: [
                // 1. Google Map View
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 13),
                  onMapCreated: (controller) => mapController = controller,
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onTap: (_) {
                    // Clicking on the map dismisses the selected shop sheet
                    setState(() {
                      _selectedShop = null;
                    });
                  },
                  markers: filteredShops.map((shop) {
                    return Marker(
                      markerId: MarkerId(shop.id),
                      position: shop.location,
                      icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(shop.category)),
                      onTap: () {
                        setState(() {
                          _selectedShop = shop;
                        });
                        // Center camera on clicked shop
                        mapController.animateCamera(
                          CameraUpdate.newLatLngZoom(shop.location, 14.5),
                        );
                      },
                    );
                  }).toSet(),
                ),

                // 2. Floating Search and Category Filter Container
                Positioned(
                  top: 50,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      // Search Card
                      Card(
                        elevation: 6,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Search stores, services, cafes...',
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val;
                                      // clear selected shop if it gets filtered out
                                      if (_selectedShop != null && !filteredShops.contains(_selectedShop)) {
                                        _selectedShop = null;
                                      }
                                    });
                                  },
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                ),
                              const VerticalDivider(width: 16, thickness: 1),
                              IconButton(
                                icon: Icon(Icons.tune, color: theme.colorScheme.primary),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Advanced map filters coming soon!')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Category Filter Chips Row
                      SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isSelected = _selectedCategory == null;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: const Text('All Stores'),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedCategory = null;
                                      _selectedShop = null;
                                    });
                                  },
                                  avatar: const Icon(Icons.storefront, size: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              );
                            }
                            final cat = _categories[index - 1];
                            final catName = cat['name']!;
                            final isSelected = _selectedCategory == catName;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(catName),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategory = isSelected ? null : catName;
                                    _selectedShop = null;
                                  });
                                },
                                avatar: Text(cat['icon']!, style: const TextStyle(fontSize: 14)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. User Location Button
                Positioned(
                  bottom: _selectedShop != null ? 280 : 100,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'location_fab',
                    mini: true,
                    onPressed: () {
                      mapController.animateCamera(CameraUpdate.newLatLng(_initialPosition));
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),

                // 4. Request Expert FAB (Sticky at the bottom-left)
                Positioned(
                  bottom: _selectedShop != null ? 280 : 100,
                  left: 16,
                  child: FloatingActionButton.extended(
                    heroTag: 'request_fab',
                    onPressed: () {
                      context.push('/request-service');
                    },
                    icon: const Icon(Icons.handyman_outlined),
                    label: const Text('Request Expert'),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),

                // 5. Shop Quick View Bottom Sheet (Sliding Panel)
                if (_selectedShop != null)
                  _buildQuickViewSheet(theme, _selectedShop!),
              ],
            );
          } else if (state is MapFailure) {
            return Center(child: Text('Error: ${state.error}'));
          }
          return const Center(child: Text('Initializing Geospatial Hub...'));
        },
      ),
    );
  }

  double _getMarkerHue(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return BitmapDescriptor.hueGreen;
      case 'plants':
        return BitmapDescriptor.hueBlue;
      case 'cafe':
        return BitmapDescriptor.hueOrange;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  Widget _buildQuickViewSheet(ThemeData theme, Shop shop) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slide Handler Bar & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    shop.category,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _selectedShop = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Shop Details Row
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    shop.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      child: Icon(Icons.store, color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(' ${shop.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(' (${shop.reviewCount} reviews)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shop.address,
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Working hours & Open Badge
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Hours: ${shop.operatingHours}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: shop.isOpen ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    shop.isOpen ? 'OPEN' : 'CLOSED',
                    style: TextStyle(
                      color: shop.isOpen ? Colors.green.shade900 : Colors.red.shade900,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'View Store Profile',
                onPressed: () {
                  context.push('/shop/${shop.id}');
                },
                type: AppButtonType.primary,
                icon: Icons.storefront,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
