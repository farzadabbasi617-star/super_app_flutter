import 'dart:math' show pi, sin, cos, sqrt, atan2, Random;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../../domain/entities/shop.dart';
import 'shop_detail_page.dart';
import 'package:go_router/go_router.dart';
import 'package:super_app_flutter/shared/widgets/app_button.dart';

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
  final LatLng _initialPosition = const LatLng(35.6892, 51.3890);

  // Filter States
  String _searchQuery = '';
  Set<String> _selectedCategories = {
    'Electronics',
    'Plants',
    'Cafe',
    'Expert',
    'Clinic',
    'Restaurant',
    'Supermarket',
    'Fashion',
    'Automotive',
    'Home',
    'Beauty',
    'Tools',
    'Books',
  };
  dynamic _selectedItem; // Holds either a Shop or a MapExpert

  // Custom Created Shops (added live!)
  final List<Shop> _customShops = [];

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
    {'name': 'Clinic', 'icon': '🩺', 'fa': 'کلینیک و مراکز حضوری'},
    {'name': 'Restaurant', 'icon': '🍔', 'fa': 'غذا و رستوران'},
    {'name': 'Supermarket', 'icon': '🛒', 'fa': 'سوپرمارکت'},
    {'name': 'Fashion', 'icon': '👗', 'fa': 'پوشاک و مد'},
    {'name': 'Automotive', 'icon': '🚗', 'fa': 'خدمات خودرو'},
    {'name': 'Home', 'icon': '🏠', 'fa': 'لوازم خانگی'},
    {'name': 'Beauty', 'icon': '💄', 'fa': 'آرایشی و زیبایی'},
    {'name': 'Tools', 'icon': '🛠️', 'fa': 'ابزارآلات و صنعتی'},
    {'name': 'Books', 'icon': '📚', 'fa': 'کتاب و تحریر'},
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

  @override
  void initState() {
    super.initState();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapBloc>().add(LoadNearbyShopsRequested(_initialPosition));
    });
  }

  Set<Marker> _buildMarkers(List<Shop> shops, List<MapExpert> experts) {
    final markers = <Marker>{};

    for (final shop in shops) {
      markers.add(
        Marker(
          markerId: MarkerId('shop_${shop.id}'),
          position: shop.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerHue(shop.category)),
          onTap: () {
            setState(() {
              _selectedItem = shop;
              _showOnboarding = false;
            });
            mapController.animateCamera(
              CameraUpdate.newLatLngZoom(shop.location, 14.5),
            );
          },
        ),
      );
    }

    for (final expert in experts) {
      markers.add(
        Marker(
          markerId: MarkerId('expert_${expert.id}'),
          position: expert.location,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          onTap: () {
            setState(() {
              _selectedItem = expert;
              _showOnboarding = false;
            });
            mapController.animateCamera(
              CameraUpdate.newLatLngZoom(expert.location, 14.5),
            );
          },
        ),
      );
    }

    return markers;
  }

  double _getMarkerHue(String category) {
    switch (category) {
      case 'Electronics':
        return BitmapDescriptor.hueGreen;
      case 'Plants':
        return BitmapDescriptor.hueAzure;
      case 'Cafe':
      case 'Restaurant':
        return BitmapDescriptor.hueRose;
      case 'Clinic':
        return BitmapDescriptor.hueCyan;
      case 'Supermarket':
        return BitmapDescriptor.hueBlue;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const double earthRadius = 6371; // km
    final dLat = (p2.latitude - p1.latitude) * pi / 180;
    final dLon = (p2.longitude - p1.longitude) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(p1.latitude * pi / 180) *
            cos(p2.latitude * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
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
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
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
        const SnackBar(
          content: Text('دسترسی موقعیت‌یابی برای همیشه مسدود شده است.'),
        ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطا در دریافت لوکیشن: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MapLoaded) {
            // Filter both Shops and Experts dynamically
            final allShopsCombined = [...state.shops, ..._customShops];
            final List<Shop> filteredShops = allShopsCombined.where((shop) {
              final matchesCategory = _selectedCategories.contains(
                shop.category,
              );
              final matchesQuery = _searchQuery.isEmpty ||
                  shop.name.toLowerCase().contains(_searchQuery.toLowerCase());
              final matchesOpen = !_showOnlyOpen || shop.isOpen;
              final matchesRating = shop.rating >= _minRating;
              final matchesRadius =
                  _calculateDistance(_initialPosition, shop.location) <=
                      _searchRadius;

              return matchesCategory &&
                  matchesQuery &&
                  matchesOpen &&
                  matchesRating &&
                  matchesRadius;
            }).toList();

            final List<MapExpert> filteredExperts = _selectedCategories
                    .contains('Expert')
                ? _allExperts.where((expert) {
                    final matchesQuery = _searchQuery.isEmpty ||
                        expert.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                        expert.specialty.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                    final matchesRating = expert.rating >= _minRating;
                    final matchesRadius =
                        _calculateDistance(_initialPosition, expert.location) <=
                            _searchRadius;

                    return matchesQuery && matchesRating && matchesRadius;
                  }).toList()
                : [];

            final markers = _buildMarkers(filteredShops, filteredExperts);

            return Stack(
              children: [
                // 1. Google Map View or Web Interactive Fallback
                kIsWeb
                    ? Container(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: MapGridPainter(
                                  isDark: theme.brightness == Brightness.dark,
                                ),
                              ),
                            ),
                            ...filteredShops.map((shop) {
                              final dx = (shop.location.longitude - _initialPosition.longitude) * 15000 + MediaQuery.of(context).size.width / 2;
                              final dy = (_initialPosition.latitude - shop.location.latitude) * 15000 + MediaQuery.of(context).size.height / 2;
                              return Positioned(
                                left: dx.clamp(20.0, MediaQuery.of(context).size.width - 120.0),
                                top: dy.clamp(140.0, MediaQuery.of(context).size.height - 220.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedItem = shop;
                                      _showOnboarding = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _selectedItem == shop ? Colors.orange : theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                                      ],
                                      border: Border.all(color: theme.colorScheme.primary, width: 2),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(_categories.firstWhere((c) => c['name'] == shop.category, orElse: () => {'icon': '🏪'})['icon']!),
                                        const SizedBox(width: 4),
                                        Text(
                                          shop.name,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: _selectedItem == shop ? Colors.white : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                            ...filteredExperts.map((expert) {
                              final dx = (expert.location.longitude - _initialPosition.longitude) * 15000 + MediaQuery.of(context).size.width / 2;
                              final dy = (_initialPosition.latitude - expert.location.latitude) * 15000 + MediaQuery.of(context).size.height / 2;
                              return Positioned(
                                left: dx.clamp(20.0, MediaQuery.of(context).size.width - 120.0),
                                top: dy.clamp(140.0, MediaQuery.of(context).size.height - 220.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedItem = expert;
                                      _showOnboarding = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade700,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                                      ],
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('👷'),
                                        const SizedBox(width: 4),
                                        Text(
                                          expert.name,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      )
                    : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 13,
                  ),
                  mapType: _currentMapType,
                  onMapCreated: (controller) {
                    mapController = controller;
                    _setMapStyle(theme);
                  },
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
                  markers: markers,
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
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
                                      hintText:
                                          'جستجوی فروشگاه، خدمات، کافه‌ها...',
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
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                ),
                              const VerticalDivider(width: 16, thickness: 1),
                              IconButton(
                                icon: Icon(
                                  Icons.tune,
                                  color: (_showOnlyOpen ||
                                          _minRating > 0 ||
                                          _searchRadius < 15.0)
                                      ? Colors.orange
                                      : theme.colorScheme.primary,
                                ),
                                onPressed: () =>
                                    _showFilterBottomSheet(context, theme),
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
                              final isSelected = _selectedCategories.length ==
                                  _categories.length;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: const Text('همه صنف‌ها'),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedCategories = _categories
                                          .map((c) => c['name']!)
                                          .toSet();
                                      _selectedItem = null;
                                    });
                                  },
                                  avatar: const Icon(
                                    Icons.storefront,
                                    size: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              );
                            }
                            final cat = _categories[index - 1];
                            final catName = cat['name']!;
                            final catFa = cat['fa']!;
                            final isSelected =
                                _selectedCategories.length == 1 &&
                                    _selectedCategories.contains(catName);

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(catFa),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategories = {catName};
                                    _selectedItem = null;
                                    _showOnboarding = false;
                                  });
                                },
                                avatar: Text(
                                  cat['icon']!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
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
                      color: theme.colorScheme.primaryContainer.withOpacity(
                        0.95,
                      ),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.tips_and_updates,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'راهنمای نقشه سوپراپلیکیشن 🌟',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'در این صفحه می‌توانید مراکز خدماتی اطراف را بیابید، یا با لمس دکمه «درخواست متخصص»، فوراً سرویس‌کار لوله‌کشی، برق، یا AC به خانه خود دعوت کنید!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
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
                    child: Icon(
                      _currentMapType == MapType.normal
                          ? Icons.satellite_outlined
                          : Icons.map_outlined,
                    ),
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

                // 6.5 Create Booth FAB (ثبت غرفه جدید)
                Positioned(
                  bottom: _selectedItem != null ? 335 : 155,
                  left: 16,
                  child: FloatingActionButton.extended(
                    heroTag: 'create_booth_fab',
                    onPressed: () {
                      _showCreateBoothDialog(context);
                    },
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('ثبت غرفه جدید'),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Text('📱', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 4),
                                Text(
                                  'الکترونیک',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('🌱', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 4),
                                Text(
                                  'گیاهان',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('☕', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 4),
                                Text(
                                  'کافه',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('👷', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 4),
                                Text(
                                  'متخصصین',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
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
            ? const ListTile(
                title: Text(
                  'موردی یافت نشد.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  ...experts.map(
                    (exp) => ListTile(
                      leading: const Icon(
                        Icons.construction_outlined,
                        color: Colors.orange,
                      ),
                      title: Text(
                        exp.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${exp.specialty} • ⭐ ${exp.rating}'),
                      onTap: () {
                        setState(() {
                          _selectedItem = exp;
                          _isSearchFocused = false;
                        });
                        FocusScope.of(context).unfocus();
                        mapController.animateCamera(
                          CameraUpdate.newLatLngZoom(exp.location, 14.5),
                        );
                      },
                    ),
                  ),
                  ...shops.map(
                    (shop) => ListTile(
                      leading: const Icon(Icons.storefront, color: Colors.grey),
                      title: Text(
                        shop.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${shop.category} • ⭐ ${shop.rating}'),
                      onTap: () {
                        setState(() {
                          _selectedItem = shop;
                          _isSearchFocused = false;
                        });
                        FocusScope.of(context).unfocus();
                        mapController.animateCamera(
                          CameraUpdate.newLatLngZoom(shop.location, 14.5),
                        );
                      },
                    ),
                  ),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تنظیمات پیشرفته نقشه',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 1. Show Open Only Toggle Switch
                    SwitchListTile(
                      title: const Text(
                        'فقط مغازه‌های باز',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'پنهان کردن کسب‌وکارهای بسته در لحظه',
                      ),
                      value: _showOnlyOpen,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        setModalState(() => _showOnlyOpen = val);
                        setState(() => _showOnlyOpen = val);
                      },
                    ),
                    const Divider(),

                    // 2. Active Categories Multi-Select Checkboxes
                    const Text(
                      'صنف‌های فعال روی نقشه',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._categories.map((cat) {
                      final catName = cat['name']!;
                      final catFa = cat['fa']!;
                      final catIcon = cat['icon']!;
                      final isChecked = _selectedCategories.contains(catName);
                      return CheckboxListTile(
                        title: Text('$catIcon $catFa'),
                        value: isChecked,
                        activeColor: theme.colorScheme.primary,
                        dense: true,
                        onChanged: (val) {
                          setModalState(() {
                            if (val == true) {
                              _selectedCategories.add(catName);
                            } else {
                              _selectedCategories.remove(catName);
                            }
                          });
                          setState(() {
                            if (val == true) {
                              _selectedCategories.add(catName);
                            } else {
                              _selectedCategories.remove(catName);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                    const Divider(),

                    // 3. Radius Slider
                    const SizedBox(height: 10),
                    Text(
                      'شعاع جستجو در نقشه: ${_searchRadius.toStringAsFixed(1)} کیلومتر',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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

                    // 4. Minimum Rating Choice Row
                    const Text(
                      'حداقل امتیاز ستاره‌ای',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [0.0, 4.0, 4.5, 4.8].map((rating) {
                        final isSelected = _minRating == rating;
                        return ChoiceChip(
                          label: Text(
                            rating == 0.0 ? 'هر امتیازی' : '$rating+ ⭐',
                          ),
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
                                _selectedCategories =
                                    _categories.map((c) => c['name']!).toSet();
                              });
                              setState(() {
                                _showOnlyOpen = false;
                                _minRating = 0.0;
                                _searchRadius = 5.0;
                                _selectedCategories =
                                    _categories.map((c) => c['name']!).toSet();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
            _buildSheetCloseHeader(
              theme,
              'فروشگاه',
              shop.category == 'Electronics'
                  ? 'الکترونیک'
                  : (shop.category == 'Plants' ? 'گل و گیاه' : 'کافه'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSheetImage(shop.imageUrl, Icons.store, theme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildRatingRow(shop.rating, '(${shop.reviewCount} نظر)'),
                      const SizedBox(height: 4),
                      Text(
                        shop.address,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHoursRow(
              'ساعت کاری:',
              shop.isOpen ? 'باز است' : 'بسته است',
              shop.isOpen,
            ),
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
                  child: Text(
                    expert.avatar,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expert.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildRatingRow(expert.rating, '(تایید شده رسمی)'),
                      const SizedBox(height: 4),
                      Text(
                        expert.specialty,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHoursRow(
              'اجرت ایاب و ذهاب:',
              '${expert.basePrice.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} تومان',
              true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'درخواست مستقیم و چت فوری با ${expert.name}',
                onPressed: () {
                  context.push(
                    '/request-service',
                  ); // Head over to services direct flow
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

  Widget _buildSheetCloseHeader(
    ThemeData theme,
    String badgeLabel,
    String subLabel,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                subLabel,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.grey),
            onPressed: () => setState(() => _selectedItem = null),
          ),
        ],
      );

  Widget _buildSheetImage(String url, IconData fallback, ThemeData theme) =>
      ClipRRect(
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
          Text(
            ' $subtext',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      );

  Widget _buildHoursRow(String leadText, String valueText, bool highlight) =>
      Row(
        children: [
          Icon(Icons.access_time, size: 16, color: HighlightColor(highlight)),
          const SizedBox(width: 6),
          Text(
            leadText,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: highlight ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              valueText,
              style: TextStyle(
                color: highlight ? Colors.green.shade900 : Colors.red.shade900,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );

  Color HighlightColor(bool h) => h ? Colors.green : Colors.red;

  void _showCreateBoothDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final hoursController = TextEditingController(text: '۰۹:۰۰ الی ۲۲:۰۰');
    final aboutController = TextEditingController();

    String selectedCatName = 'Electronics'; // Default selected category name
    String selectedCatFa = 'الکترونیک و دیجیتال';
    String selectedIcon = '📱';

    final categoriesList = [
      {'name': 'Electronics', 'icon': '📱', 'fa': 'الکترونیک و دیجیتال'},
      {'name': 'Plants', 'icon': '🌱', 'fa': 'گل و گیاه آپارتمانی'},
      {'name': 'Cafe', 'icon': '☕', 'fa': 'کافه و دسر'},
      {'name': 'Clinic', 'icon': '🩺', 'fa': 'کلینیک و سلامت'},
      {'name': 'Restaurant', 'icon': '🍔', 'fa': 'رستوران و فست‌فود'},
      {'name': 'Supermarket', 'icon': '🛒', 'fa': 'سوپرمارکت و خواربار'},
      {'name': 'Fashion', 'icon': '👗', 'fa': 'پوشاک و مد'},
      {'name': 'Automotive', 'icon': '🚗', 'fa': 'خدمات خودرو'},
      {'name': 'Home', 'icon': '🏠', 'fa': 'لوازم خانگی'},
      {'name': 'Beauty', 'icon': '💄', 'fa': 'آرایشی و زیبایی'},
      {'name': 'Tools', 'icon': '🛠️', 'fa': 'ابزارآلات و صنعتی'},
      {'name': 'Books', 'icon': '📚', 'fa': 'کتاب و تحریر'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'ثبت و ایجاد غرفه جدید 🏪',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              content: Directionality(
                textDirection: TextDirection.rtl,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'اطلاعات کسب‌وکار خود را وارد کنید تا غرفه شما فوراً روی نقشه سوپراپلیکیشن فعال شود:',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      // 1. Name
                      const Text(
                        'نام غرفه / کسب‌وکار',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'مثال: گالری پوشاک شیک‌پوش',
                          prefixIcon: const Icon(Icons.storefront, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. Category Dropdown
                      const Text(
                        'صنف و دسته‌بندی اصلی غرفه',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCatName,
                            isExpanded: true,
                            items: categoriesList.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat['name']!,
                                child: Text('${cat['icon']!} ${cat['fa']!}'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final matched = categoriesList.firstWhere(
                                  (element) => element['name'] == val,
                                );
                                setModalState(() {
                                  selectedCatName = val;
                                  selectedCatFa = matched['fa']!;
                                  selectedIcon = matched['icon']!;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. Address
                      const Text(
                        'آدرس دقیق فیزیکی',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          hintText: 'مثال: تهران، میدان ونک، پلاک ۱۵',
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 4. Phone
                      const Text(
                        'شماره تماس غرفه',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'مثال: ۰۲۱۸۸۷۷۶۶۵۵',
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 5. Operating Hours
                      const Text(
                        'ساعت کاری غرفه',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: hoursController,
                        decoration: InputDecoration(
                          hintText: 'مثال: ۰۹:۰۰ الی ۲۲:۰۰',
                          prefixIcon: const Icon(Icons.access_time, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 6. About Description
                      const Text(
                        'توضیحات و درباره غرفه',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: aboutController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText:
                              'درباره خدمات غرفه، کیفیت محصولات و شعار غرفه بنویسید...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('انصراف'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final address = addressController.text.trim();
                    final phone = phoneController.text.trim();
                    final hours = hoursController.text.trim();
                    final about = aboutController.text.trim();

                    if (name.isEmpty || address.isEmpty || phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'لطفاً فیلدهای نام، آدرس و تلفن را پر کنید!',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Create dynamic products for the new booth based on category
                    List<BoothProduct> customProducts = [];
                    if (selectedCatName == 'Electronics') {
                      customProducts = const [
                        BoothProduct(
                          name: 'کابل شارژر Fast تایپ سی',
                          price: '۱۵۰,۰۰۰ تومان',
                          icon: '🔌',
                          description: 'کابل فست شارژ بادوام و کنفی',
                        ),
                        BoothProduct(
                          name: 'پاوربانک مسافرتی ۲۰هزار',
                          price: '۲,۵۰۰,۰۰۰ تومان',
                          icon: '🔋',
                          description: 'شارژ همزمان سه دستگاه با ظرفیت واقعی',
                        ),
                      ];
                    } else if (selectedCatName == 'Plants') {
                      customProducts = const [
                        BoothProduct(
                          name: 'گلدان پوتوس رونده سبز',
                          price: '۱۸۰,۰۰۰ تومان',
                          icon: '🍀',
                          description: 'پوتوس شاداب با نگهداری آسان آپارتمانی',
                        ),
                        BoothProduct(
                          name: 'کود غنی مایع نیتروژن',
                          price: '۹۰,۰۰۰ تومان',
                          icon: '🧪',
                          description: 'محلول رشد سریع و شادابی و قطره پاشی',
                        ),
                      ];
                    } else if (selectedCatName == 'Cafe') {
                      customProducts = const [
                        BoothProduct(
                          name: 'اسپرسو دوبل اسپشیالتی',
                          price: '۸۰,۰۰۰ تومان',
                          icon: '☕',
                          description: 'دانه‌های ممتاز اسپشیالتی عربیکا',
                        ),
                        BoothProduct(
                          name: 'کرواسان داغ پخت روز',
                          price: '۱۲۰,۰۰۰ تومان',
                          icon: '🥐',
                          description:
                              'کرواسان فرانسوی ترد با فیلینگ شکلات فندقی',
                        ),
                      ];
                    } else if (selectedCatName == 'Clinic') {
                      customProducts = const [
                        BoothProduct(
                          name: 'ویزیت پزشک عمومی حضوری',
                          price: '۱۵۰,۰۰۰ تومان',
                          icon: '🩺',
                          description: 'ویزیت حضوری و معاینه بالینی کامل',
                        ),
                        BoothProduct(
                          name: 'خدمت سرم‌تراپی و تزریقات',
                          price: '۱۲۰,۰۰۰ تومان',
                          icon: '💉',
                          description:
                              'تزریق سرم و آمپول توسط کادر مجرب پرستاری',
                        ),
                      ];
                    } else if (selectedCatName == 'Restaurant') {
                      customProducts = const [
                        BoothProduct(
                          name: 'چلوکباب کوبیده نگین‌دار',
                          price: '۲۸۰,۰۰۰ تومان',
                          icon: '🍢',
                          description:
                              'دو سیخ کباب گوسفندی زعفرانی با برنج ممتاز',
                        ),
                        BoothProduct(
                          name: 'جوجه کباب زعفرانی مخصوص',
                          price: '۲۱۰,۰۰۰ تومان',
                          icon: '🍗',
                          description: 'جوجه کباب سینه بدون استخوان نرم و لذیذ',
                        ),
                      ];
                    } else if (selectedCatName == 'Supermarket') {
                      customProducts = const [
                        BoothProduct(
                          name: 'پک تنقلات عصرانه خانواده',
                          price: '۱۳۵,۰۰۰ تومان',
                          icon: '🍿',
                          description: 'شامل چیپس، پفک، پاپ‌کورن و نوشابه قوطی',
                        ),
                        BoothProduct(
                          name: 'روغن پخت و پز آفتابگردان',
                          price: '۱۹۰,۰۰۰ تومان',
                          icon: '🧴',
                          description: 'بطری ۱.۵ لیتری روغن خالص تصفیه شده',
                        ),
                      ];
                    } else if (selectedCatName == 'Fashion') {
                      customProducts = const [
                        BoothProduct(
                          name: 'تی‌شرت نخی آستین کوتاه',
                          price: '۳۵۰,۰۰۰ تومان',
                          icon: '👕',
                          description: 'تی‌شرت نخی ۱۰۰٪ خالص ضد حساسیت',
                        ),
                        BoothProduct(
                          name: 'شلوار جین تیره کلاسیک',
                          price: '۶۸۰,۰۰۰ تومان',
                          icon: '👖',
                          description: 'جین اصل ترک با پاخور شکیل و عالی',
                        ),
                      ];
                    } else if (selectedCatName == 'Automotive') {
                      customProducts = const [
                        BoothProduct(
                          name: 'تعویض روغن موتور و فیلترها',
                          price: '۸۵۰,۰۰۰ تومان',
                          icon: '🔧',
                          description:
                              'روغن ۱۰W40 مرغوب با تعویض فیلتر روغن و هوا',
                        ),
                        BoothProduct(
                          name: 'تنظیم باد تخصصی و آپارات',
                          price: '۹۰,۰۰۰ تومان',
                          icon: '🚗',
                          description: 'بررسی باد و بالانس چهار چرخ خودرو',
                        ),
                      ];
                    } else if (selectedCatName == 'Home') {
                      customProducts = const [
                        BoothProduct(
                          name: 'ساعت دیواری طرح مدرن فانتزی',
                          price: '۴۸۰,۰۰۰ تومان',
                          icon: '🕰️',
                          description: 'ساعت دیواری موتور تایوانی بی‌صدا',
                        ),
                        BoothProduct(
                          name: 'آباژور رومیزی پایه چوبی دنج',
                          price: '۶۲۰,۰۰۰ تومان',
                          icon: '💡',
                          description: 'نورپردازی گرم و رویایی مخصوص اتاق‌خواب',
                        ),
                      ];
                    } else if (selectedCatName == 'Beauty') {
                      customProducts = const [
                        BoothProduct(
                          name: 'فیشیال و پاکسازی عمیق پوست',
                          price: '۳۸۰,۰۰۰ تومان',
                          icon: '🧼',
                          description:
                              'لایه‌برداری، آبرسانی و ماسک جوانسازی شاداب‌کننده',
                        ),
                        BoothProduct(
                          name: 'کاشت ناخن پایه و طراحی زیبا',
                          price: '۴۵۰,۰۰۰ تومان',
                          icon: '💅',
                          description: 'کاشت ناخن پودری با طراحی دلخواه شما',
                        ),
                      ];
                    } else if (selectedCatName == 'Tools') {
                      customProducts = const [
                        BoothProduct(
                          name: 'پیچ‌گوشتی برقی و شارژی رونیکس',
                          price: '۱,۹۰۰,۰۰۰ تومان',
                          icon: '🛠️',
                          description: 'رونیکس موتور قوی با دو باتری لیتیومی',
                        ),
                        BoothProduct(
                          name: 'جعبه ابزار فلزی چند طبقه بزرگ',
                          price: '۴۸۰,۰۰۰ تومان',
                          icon: '🧰',
                          description: 'جعبه ابزار تمام فلزی ضد زنگ بادوام',
                        ),
                      ];
                    } else {
                      // Books
                      customProducts = const [
                        BoothProduct(
                          name: 'دفترچه یادداشت طرح چرم نفیس',
                          price: '۹۵,۰۰۰ تومان',
                          icon: '📔',
                          description:
                              'کاغذ کرم گرم بالا بدون خط خوردگی مناسب هدیه',
                        ),
                        BoothProduct(
                          name: 'روان‌نویس ژلی لاکچری مشکی',
                          price: '۸۵,۰۰۰ تومان',
                          icon: '✒️',
                          description:
                              'نوک ساچمه‌ای استیل فوق روان روان‌نویس ژل',
                        ),
                      ];
                    }

                    // Create unique ID for the custom booth
                    final customId =
                        'custom_${DateTime.now().millisecondsSinceEpoch}';

                    // Save details in ShopDetailPage's static cache so it opens beautifully!
                    ShopDetailPage.customCreatedShops.add({
                      'id': customId,
                      'name': name,
                      'category': selectedCatFa,
                      'isFixedClinic': selectedCatName == 'Clinic',
                      'rating': 5.0, // Brand new!
                      'reviews': 0,
                      'address': address,
                      'phone': phone,
                      'hours': hours,
                      'about': about.isEmpty
                          ? 'یک غرفه بومی و معتبر ثبت شده در موقعیت یابی سوپراپلیکیشن.'
                          : about,
                      'avatar': selectedIcon,
                      'products': customProducts,
                      'defaultReviews': <UserReview>[],
                    });

                    // Add new shop to the local map shops list!
                    final newShop = Shop(
                      id: customId,
                      name: name,
                      description:
                          about.isEmpty ? 'غرفه تازه تاسیس در تهران' : about,
                      location: LatLng(
                        _initialPosition.latitude +
                            (Random().nextDouble() - 0.5) * 0.015,
                        _initialPosition.longitude +
                            (Random().nextDouble() - 0.5) * 0.015,
                      ), // Random offset near map center
                      imageUrl:
                          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=150', // placeholder
                      category: selectedCatName,
                      rating: 5.0,
                      reviewCount: 0,
                      address: address,
                      phoneNumber: phone,
                      website: '',
                      isOpen: true,
                      operatingHours: hours,
                    );

                    setState(() {
                      _customShops.add(newShop);
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '🎉 تبریک! غرفه «$name» با دسته‌بندی «$selectedCatFa» و آیکون $selectedIcon روی نقشه ایجاد شد!',
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'ایجاد غرفه غرفه‌دار 🚀',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
}

class MapGridPainter extends CustomPainter {
  final bool isDark;
  MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.06)
      ..strokeWidth = 1;

    const gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
