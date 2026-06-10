import 'dart:math' show pi, sin, cos, sqrt, atan2;
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

// 1. Unified Cluster Item Wrapper for Map Discovery
class MapClusterItem with ClusterItem {
  final dynamic item; // Can be a Shop or a MapExpert

  MapClusterItem({required this.item});

  @override
  LatLng get location {
    if (item is Shop) {
      return (item as Shop).location;
    } else if (item is MapExpert) {
      return (item as MapExpert).location;
    }
    return const LatLng(0, 0);
  }
}

// 2. Expert Map Model Representation
class MapExpert {
  final String id;
  final String name;
  final String specialty;
  final LatLng location;
  final double rating;
  final String avatar;
  final double basePrice;
  final bool isAvailable;

  const MapExpert({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.rating,
    required this.avatar,
    required this.basePrice,
    this.isAvailable = true,
  });
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  late ClusterManager<MapClusterItem> _clusterManager;
  final LatLng _initialPosition = const LatLng(35.6892, 51.3890);

  // Filter States
  String _searchQuery = '';
  String? _selectedCategory;
  dynamic _selectedItem; // Holds either a Shop or a MapExpert

  // Advanced Tune Filters
  bool _showOnlyOpen = false;
  double _minRating = 0.0;
  double _searchRadius = 5.0; // Default search radius in km
  bool _isSearchFocused = false;

  // Onboarding & Map Type States
  bool _showOnboarding = true;
  MapType _currentMapType = MapType.normal;

  final List<Map<String, String>> _categories = [
    {'name': 'Electronics', 'icon': '📱', 'fa': 'الکترونیک'},
    {'name': 'Plants', 'icon': '🌱', 'fa': 'گل و گیاه'},
    {'name': 'Cafe', 'icon': '☕', 'fa': 'کافه'},
    {'name': 'Expert', 'icon': '👨‍🔧', 'fa': 'متخصصین'},
  ];

  // Mock Database of Real-time Experts nearby
  final List<MapExpert> _allExperts = [
    const MapExpert(
      id: 'exp_1',
      name: 'علی رضایی',
      specialty: 'متخصص ارشد تاسیسات و لوله‌کشی',
      location: LatLng(35.6850, 51.3800), // ~1.1km away
      rating: 4.9,
      avatar: '👨‍🔧',
      basePrice: 150000,
    ),
    const MapExpert(
      id: 'exp_2',
      name: 'سینا محمدی',
      specialty: 'تکنسین برق ساختمان و عیب‌یابی',
      location: LatLng(35.6920, 51.3980), // ~1.0km away
      rating: 4.8,
      avatar: '⚡',
      basePrice: 120000,
    ),
    const MapExpert(
      id: 'exp_3',
      name: 'میلاد کریمی',
      specialty: 'تکنسین سیستم‌های سرمایشی و کولر',
      location: LatLng(35.6780, 51.4050), // ~2.1km away
      rating: 4.7,
      avatar: '❄️',
      basePrice: 140000,
    ),
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

  void _initClusterManager() {
    _clusterManager = ClusterManager<MapClusterItem>(
      [],
      _updateMarkers,
      markerBuilder: _getMarkerBuilder,
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers = markers;
    });
  }

  // Builder function for clusters/markers (Polymorphic: supports Shop and MapExpert)
  Future<Marker> _getMarkerBuilder(Cluster<MapClusterItem> cluster) async {
    final isMultiple = cluster.isMultiple;
    final item = cluster.items.first.item;

    double hue = BitmapDescriptor.hueRed;
    if (!isMultiple) {
      if (item is Shop) {
        hue = _getMarkerHue(item.category);
      } else if (item is MapExpert) {
        hue = BitmapDescriptor.hueOrange; // Orange markers for experts
      }
    }

    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      onTap: () {
        if (isMultiple) {
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(cluster.location, cluster.zoom + 2),
          );
        } else {
          setState(() {
            _selectedItem = item;
            _showOnboarding = false; // Hide onboarding if they interact
          });
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(cluster.location, 14.5),
          );
        }
      },
      icon: isMultiple 
          ? await _getClusterIcon(cluster.count)
          : BitmapDescriptor.defaultMarkerWithHue(hue),
    );
  }

  Future<BitmapDescriptor> _getClusterIcon(int count) async {
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

  // Haversine formula to filter markers within radius
  double _calculateDistance(LatLng p1, LatLng p2) {
    const double earthRadius = 6371; // km
    final dLat = (p2.latitude - p1.latitude) * pi / 180;
    final dLon = (p2.longitude - p1.longitude) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(p1.latitude * pi / 180) * cos(p2.latitude * pi / 180) *
              sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  void _setMapStyle(ThemeData theme) {
    if (_currentMapType == MapType.satellite) {
      mapController.setMapStyle(null);
    } else if (theme.brightness == Brightness.dark) {
      mapController.setMapStyle(_darkMapStyle);
    } else {
      mapController.setMapStyle(null);
    }
  }

  // Toggle Map Style normal <-> satellite
  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
    _setMapStyle(Theme.of(context));
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapLoaded) {
            _syncClusterItems(state.shops);
          }
        },
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MapLoaded) {
            // Filter both Shops and Experts dynamically
            final List<Shop> filteredShops = _selectedCategory == 'Expert' 
                ? [] 
                : state.shops.where((shop) {
                    final matchesCategory = _selectedCategory == null || shop.category == _selectedCategory;
                    final matchesQuery = _searchQuery.isEmpty || 
                        shop.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesOpen = !_showOnlyOpen || shop.isOpen;
                    final matchesRating = shop.rating >= _minRating;
                    final matchesRadius = _calculateDistance(_initialPosition, shop.location) <= _searchRadius;
                    
                    return matchesCategory && matchesQuery && matchesOpen && matchesRating && matchesRadius;
                  }).toList();

            final List<MapExpert> filteredExperts = (_selectedCategory == null || _selectedCategory == 'Expert')
                ? _allExperts.where((expert) {
                    final matchesQuery = _searchQuery.isEmpty || 
                        expert.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        expert.specialty.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesRating = expert.rating >= _minRating;
                    final matchesRadius = _calculateDistance(_initialPosition, expert.location) <= _searchRadius;
                    
                    return matchesQuery && matchesRating && matchesRadius;
                  }).toList()
                : [];

            // Combine both Shop and Expert items for the ClusterManager
            final List<MapClusterItem> combinedItems = [];
            combinedItems.addAll(filteredShops.map((s) => MapClusterItem(item: s)));
            combinedItems.addAll(filteredExperts.map((e) => MapClusterItem(item: e)));
            
            _clusterManager.setItems(combinedItems);

            return Stack(
              children: [
                // 1. Google Map View
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 13),
                  mapType: _currentMapType,
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
                      _selectedItem = null;
                      _isSearchFocused = false;
                    });
                    FocusScope.of(context).unfocus();
                  },
                  markers: _markers,
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
                                        _selectedItem = null;
                                        _showOnboarding = false;
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
                                icon: Icon(Icons.tune, color: (_showOnlyOpen || _minRating > 0 || _searchRadius < 15.0) ? Colors.orange : theme.colorScheme.primary),
                                onPressed: () => _showFilterBottomSheet(context, theme),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Search Suggestions Overlay
                      if (_isSearchFocused && _searchQuery.isNotEmpty)
                        _buildSearchSuggestions(filteredShops, filteredExperts),

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
                                      _selectedItem = null;
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
                                    _selectedItem = null;
                                    _showOnboarding = false;
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

                // 3. Floating Onboarding Instruction Card (Fades out when closed)
                if (_showOnboarding)
                  Positioned(
                    top: 170,
                    left: 20,
                    right: 20,
                    child: Card(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.95),
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.tips_and_updates, color: theme.colorScheme.primary, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'راهنمای نقشه سوپراپلیکیشن 🌟',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'در این صفحه می‌توانید مراکز خدماتی اطراف را بیابید، یا با لمس دکمه «درخواست متخصص»، فوراً سرویس‌کار لوله‌کشی، برق، یا AC به خانه خود دعوت کنید!',
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setState(() {
                                  _showOnboarding = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 4. Map Style Toggle Button (Standard vs Satellite)
                Positioned(
                  bottom: _selectedItem != null ? 335 : 155,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'style_fab',
                    mini: true,
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.primary,
                    onPressed: _toggleMapType,
                    child: Icon(_currentMapType == MapType.normal ? Icons.satellite_outlined : Icons.map_outlined),
                  ),
                ),

                // 5. User Location Button
                Positioned(
                  bottom: _selectedItem != null ? 280 : 100,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'location_fab',
                    mini: true,
                    onPressed: _getCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),

                // 6. Request Expert FAB
                Positioned(
                  bottom: _selectedItem != null ? 280 : 100,
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

                // 7. Map Legend Guide (Floating on the map)
                if (_selectedItem == null && !_isSearchFocused)
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Card(
                      color: theme.colorScheme.surface.withOpacity(0.9),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(children: [Text('📱', style: TextStyle(fontSize: 12)), SizedBox(width: 4), Text('الکترونیک', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
                            Row(children: [Text('🌱', style: TextStyle(fontSize: 12)), SizedBox(width: 4), Text('گیاهان', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
                            Row(children: [Text('☕', style: TextStyle(fontSize: 12)), SizedBox(width: 4), Text('کافه', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
                            Row(children: [Text('👷', style: TextStyle(fontSize: 12)), SizedBox(width: 4), Text('متخصصین', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange))]),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 8. Polymorphic Quick View Sliding Panel
                if (_selectedItem != null)
                  _buildPolymorphicQuickView(theme, _selectedItem),
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

  void _syncClusterItems(List<Shop> shops) {
    final combined = <MapClusterItem>[];
    combined.addAll(shops.map((s) => MapClusterItem(item: s)));
    combined.addAll(_allExperts.map((e) => MapClusterItem(item: e)));
    _clusterManager.setItems(combined);
  }

  // Combined suggestions builder
  Widget _buildSearchSuggestions(List<Shop> shops, List<MapExpert> experts) {
    final totalCount = shops.length + experts.length;
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(top: 4, left: 4, right: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 240),
        child: totalCount == 0
            ? const ListTile(title: Text('موردی یافت نشد.', style: TextStyle(color: Colors.grey)))
            : ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  ...experts.map((exp) => ListTile(
                    leading: const Icon(Icons.construction_outlined, color: Colors.orange),
                    title: Text(exp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${exp.specialty} • ⭐ ${exp.rating}'),
                    onTap: () {
                      setState(() {
                        _selectedItem = exp;
                        _isSearchFocused = false;
                      });
                      FocusScope.of(context).unfocus();
                      mapController.animateCamera(CameraUpdate.newLatLngZoom(exp.location, 14.5));
                    },
                  )),
                  ...shops.map((shop) => ListTile(
                    leading: const Icon(Icons.storefront, color: Colors.grey),
                    title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${shop.category} • ⭐ ${shop.rating}'),
                    onTap: () {
                      setState(() {
                        _selectedItem = shop;
                        _isSearchFocused = false;
                      });
                      FocusScope.of(context).unfocus();
                      mapController.animateCamera(CameraUpdate.newLatLngZoom(shop.location, 14.5));
                    },
                  )),
                ],
              ),
      ),
    );
  }

  // Advanced Tuning Filter sheet with Radius slider
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

                  // 2. Radius Slider
                  const SizedBox(height: 10),
                  Text(
                    'شعاع جستجو در نقشه: ${_searchRadius.toStringAsFixed(1)} کیلومتر',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Slider(
                    value: _searchRadius,
                    min: 1.0,
                    max: 15.0,
                    divisions: 14,
                    label: '${_searchRadius.toStringAsFixed(0)}km',
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      setModalState(() => _searchRadius = val);
                      setState(() => _searchRadius = val);
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 3. Minimum Rating Choice Row
                  const Text('حداقل امتیاز ستاره‌ای', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _showOnlyOpen = false;
                              _minRating = 0.0;
                              _searchRadius = 5.0;
                            });
                            setState(() {
                              _showOnlyOpen = false;
                              _minRating = 0.0;
                              _searchRadius = 5.0;
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

  // Polymorphic bottom quick view (Handles both Shop and MapExpert)
  Widget _buildPolymorphicQuickView(ThemeData theme, dynamic item) {
    if (item is Shop) {
      return _buildShopQuickView(theme, item);
    } else if (item is MapExpert) {
      return _buildExpertQuickView(theme, item);
    }
    return const SizedBox.shrink();
  }

  Widget _buildShopQuickView(ThemeData theme, Shop shop) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _sheetDecoration(theme),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSheetCloseHeader(theme, 'فروشگاه', shop.category == 'Electronics' ? 'الکترونیک' : (shop.category == 'Plants' ? 'گل و گیاه' : 'کافه')),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSheetImage(shop.imageUrl, Icons.store, theme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shop.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      _buildRatingRow(shop.rating, '(${shop.reviewCount} نظر)'),
                      const SizedBox(height: 4),
                      Text(shop.address, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHoursRow('ساعت کاری:', shop.isOpen ? 'باز است' : 'بسته است', shop.isOpen),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'مشاهده پروفایل فروشگاه',
                onPressed: () => context.push('/shop/${shop.id}'),
                type: AppButtonType.primary,
                icon: Icons.storefront,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertQuickView(ThemeData theme, MapExpert expert) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _sheetDecoration(theme),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSheetCloseHeader(theme, 'متخصص آماده به کار', 'موقعیت زنده'),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(expert.avatar, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(expert.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      _buildRatingRow(expert.rating, '(تایید شده رسمی)'),
                      const SizedBox(height: 4),
                      Text(expert.specialty, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHoursRow('اجرت ایاب و ذهاب:', '${expert.basePrice.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} تومان', true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'درخواست مستقیم و چت فوری با ${expert.name}',
                onPressed: () {
                  context.push('/request-service'); // Head over to services direct flow
                },
                type: AppButtonType.primary,
                icon: Icons.chat_bubble_outline_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Common sheet widget helpers
  BoxDecoration _sheetDecoration(ThemeData theme) => BoxDecoration(
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
  );

  Widget _buildSheetCloseHeader(ThemeData theme, String badgeLabel, String subLabel) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeLabel,
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Text(subLabel, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
      IconButton(
        icon: const Icon(Icons.cancel, color: Colors.grey),
        onPressed: () => setState(() => _selectedItem = null),
      ),
    ],
  );

  Widget _buildSheetImage(String url, IconData fallback, ThemeData theme) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
      url,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 70,
        height: 70,
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        child: Icon(fallback, color: theme.colorScheme.primary),
      ),
    ),
  );

  Widget _buildRatingRow(double rating, String subtext) => Row(
    children: [
      const Icon(Icons.star, color: Colors.amber, size: 18),
      Text(' $rating', style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(' $subtext', style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ],
  );

  Widget _buildHoursRow(String leadText, String valueText, bool highlight) => Row(
    children: [
      Icon(Icons.access_time, size: 16, color: HighlightColor(highlight)),
      const SizedBox(width: 6),
      Text(leadText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: highlight ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          valueText,
          style: TextStyle(color: highlight ? Colors.green.shade900 : Colors.red.shade900, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );

  Color HighlightColor(bool h) => h ? Colors.green : Colors.red;

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
}
