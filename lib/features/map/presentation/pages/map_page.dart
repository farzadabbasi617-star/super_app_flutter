import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../../domain/entities/shop.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';

// 1. Cluster Item Wrapper for Shop (Implements ClusterItem)
class ShopClusterItem with ClusterItem {
  final Shop shop;

  ShopClusterItem({required this.shop});

  @override
  LatLng get location => shop.location;
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  late ClusterManager<ShopClusterItem> _clusterManager;
  final LatLng _initialPosition = const LatLng(35.6892, 51.3890);

  // Filter States
  String _searchQuery = '';
  String? _selectedCategory;
  Shop? _selectedShop;

  // Advanced Tune Filters
  bool _showOnlyOpen = false;
  double _minRating = 0.0;
  bool _isSearchFocused = false;

  final List<Map<String, String>> _categories = [
    {'name': 'Electronics', 'icon': '📱', 'fa': 'الکترونیک'},
    {'name': 'Plants', 'icon': '🌱', 'fa': 'گل و گیاه'},
    {'name': 'Cafe', 'icon': '☕', 'fa': 'کافه'},
  ];

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initClusterManager();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapBloc>().add(LoadNearbyShopsRequested(_initialPosition));
    });
  }

  // 2. Initialize Google Maps Cluster Manager
  void _initClusterManager() {
    _clusterManager = ClusterManager<ShopClusterItem>(
      [], // Initial empty list, will be updated dynamically
      _updateMarkers,
      markerBuilder: _getMarkerBuilder,
    );
  }

  // Callback to update local markers set when cluster manager processes clusters
  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers = markers;
    });
  }

  // Builder function for clusters/markers
  Future<Marker> _getMarkerBuilder(Cluster<ShopClusterItem> cluster) async {
    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      onTap: () {
        if (cluster.isMultiple) {
          // If it is a cluster of multiple stores, zoom in on tap!
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(cluster.location, cluster.zoom + 2),
          );
        } else {
          // If it is a single store marker, select and show bottom quick view!
          final shop = cluster.items.first.shop;
          setState(() {
            _selectedShop = shop;
          });
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(shop.location, 14.5),
          );
        }
      },
      icon: cluster.isMultiple 
          ? await _getClusterIcon(cluster.count)
          : BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(cluster.items.first.shop.category)),
    );
  }

  // Generate dynamic cluster badge icons with counts
  Future<BitmapDescriptor> _getClusterIcon(int count) async {
    // In a real flutter app, we would use a canvas to draw a beautiful circular cluster badge
    // with the count text in the center. For a robust build-friendly mock, we use default colored marker.
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
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

  void _setMapStyle(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      mapController.setMapStyle(_darkMapStyle);
    } else {
      mapController.setMapStyle(null);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خدمات لوکیشن غیرفعال است.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('دسترسی به موقعیت‌یابی رد شد.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('دسترسی موقعیت‌یابی برای همیشه مسدود شده است.')),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14.5));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('موقعیت یابی GPS با موفقیت انجام شد!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در دریافت لوکیشن: $e')),
      );
    }
  }

  static const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#2c2c2c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#000000"
      }
    ]
  }
]
''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapLoaded) {
            // Update cluster manager items when shops are loaded from repository
            final clusterItems = state.shops.map((s) => ShopClusterItem(shop: s)).toList();
            _clusterManager.setItems(clusterItems);
          }
        },
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MapLoaded) {
            // Filter shops on client-side dynamically in real-time
            final filteredShops = state.shops.where((shop) {
              final matchesCategory = _selectedCategory == null || shop.category == _selectedCategory;
              final matchesQuery = _searchQuery.isEmpty || 
                  shop.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  shop.category.toLowerCase().contains(_searchQuery.toLowerCase());
              final matchesOpen = !_showOnlyOpen || shop.isOpen;
              final matchesRating = shop.rating >= _minRating;
              
              return matchesCategory && matchesQuery && matchesOpen && matchesRating;
            }).toList();

            // Sync the filtered list to the cluster manager
            _clusterManager.setItems(filteredShops.map((s) => ShopClusterItem(shop: s)).toList());

            return Stack(
              children: [
                // 1. Google Map View
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 13),
                  onMapCreated: (controller) {
                    mapController = controller;
                    _clusterManager.setMapId(controller.mapId);
                    _setMapStyle(theme);
                  },
                  onCameraMove: _clusterManager.onCameraMove,
                  onCameraIdle: _clusterManager.onCameraIdle,
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onTap: (_) {
                    setState(() {
                      _selectedShop = null;
                      _isSearchFocused = false;
                    });
                    FocusScope.of(context).unfocus();
                  },
                  markers: _markers, // Controlled and populated dynamically by ClusterManager!
                ),

                // 2. Floating Search and Advanced Filters
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
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    setState(() {
                                      _isSearchFocused = hasFocus;
                                    });
                                  },
                                  child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'جستجوی فروشگاه، خدمات، کافه‌ها...',
                                    border: InputBorder.none,
                                  ),
                                    onChanged: (val) {
                                      setState(() {
                                        _searchQuery = val;
                                        if (_selectedShop != null && !filteredShops.contains(_selectedShop)) {
                                          _selectedShop = null;
                                        }
                                      });
                                    },
                                  ),
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
                                icon: Icon(Icons.tune, color: (_showOnlyOpen || _minRating > 0) ? Colors.orange : theme.colorScheme.primary),
                                onPressed: () => _showFilterBottomSheet(context, theme),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Search Suggestions Overlay List
                      if (_isSearchFocused && _searchQuery.isNotEmpty)
                        _buildSearchSuggestions(filteredShops),

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
                                  label: const Text('همه صنف‌ها'),
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
                            final catFa = cat['fa']!;
                            final isSelected = _selectedCategory == catName;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(catFa),
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

                // 3. User Location Button (Adjusts height dynamically if sheet is open)
                Positioned(
                  bottom: _selectedShop != null ? 280 : 100,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'location_fab',
                    mini: true,
                    onPressed: _getCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),

                // 4. Request Expert FAB
                Positioned(
                  bottom: _selectedShop != null ? 280 : 100,
                  left: 16,
                  child: FloatingActionButton.extended(
                    heroTag: 'request_fab',
                    onPressed: () {
                      context.push('/request-service');
                    },
                    icon: const Icon(Icons.handyman_outlined),
                    label: const Text('درخواست متخصص'),
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

  // Beautiful suggestions list overlay card
  Widget _buildSearchSuggestions(List<Shop> matchedShops) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(top: 4, left: 4, right: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 240),
        child: matchedShops.isEmpty
            ? const ListTile(title: Text('موردی یافت نشد.', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: matchedShops.length,
                itemBuilder: (context, index) {
                  final shop = matchedShops[index];
                  return ListTile(
                    leading: const Icon(Icons.storefront, color: Colors.grey),
                    title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${shop.category} • ${shop.rating}⭐'),
                    onTap: () {
                      setState(() {
                        _selectedShop = shop;
                        _isSearchFocused = false;
                      });
                      FocusScope.of(context).unfocus();
                      mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(shop.location, 14.5),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  // Modern Modal Bottom Sheet for Advanced Map Tuning (Filtering)
  void _showFilterBottomSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تنظیمات پیشرفته نقشه',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 1. Show Open Only Toggle Switch
                  SwitchListTile(
                    title: const Text('فقط مغازه‌های باز', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('پنهان کردن کسب‌وکارهای بسته در لحظه'),
                    value: _showOnlyOpen,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      setModalState(() => _showOnlyOpen = val);
                      setState(() => _showOnlyOpen = val);
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 2. Minimum Rating Radio Row
                  const Text('حداقل امتیاز ستاره‌ای', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [0.0, 4.0, 4.5, 4.8].map((rating) {
                      final isSelected = _minRating == rating;
                      return ChoiceChip(
                        label: Text(rating == 0.0 ? 'هر امتیازی' : '$rating+ ⭐'),
                        selected: isSelected,
                        onSelected: (_) {
                          setModalState(() => _minRating = rating);
                          setState(() => _minRating = rating);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _showOnlyOpen = false;
                              _minRating = 0.0;
                            });
                            setState(() {
                              _showOnlyOpen = false;
                              _minRating = 0.0;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('حذف فیلترها'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          child: const Text('اعمال فیلترها'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                    shop.category == 'Electronics' ? 'الکترونیک' : (shop.category == 'Plants' ? 'گل و گیاه' : (shop.category == 'Cafe' ? 'کافه' : shop.category)),
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
                          Text(' (${shop.reviewCount} نظر)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                  'ساعت کاری: ${shop.operatingHours}',
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
                    shop.isOpen ? 'باز است' : 'بسته است',
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
                text: 'مشاهده پروفایل فروشگاه',
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
