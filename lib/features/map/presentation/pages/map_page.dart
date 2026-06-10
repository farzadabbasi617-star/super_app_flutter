import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import 'shop_detail_page.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  late ClusterManager _clusterManager;
  final LatLng _initialPosition = const LatLng(35.6892, 51.3890);

  @override
  void initState() {
    super.initState();
    _initClusterManager();
    / Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapBloc>().add(LoadNearbyShopsRequested(_initialPosition));
    });
  }

  void _initClusterManager() {
    / The cluster manager requires a list of items that implement ClusterItem
    / We'll create a wrapper class for Shop
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MapLoaded) {
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 13),
                  onMapCreated: (controller) => mapController = controller,
                  markers: state.shops.map((shop) {
                    return Marker(
                      markerId: MarkerId(shop.id),
                      position: shop.location,
                      infoWindow: InfoWindow(
                        title: shop.name,
                        snippet: '${shop.category} - ${shop.rating}⭐',
                        onTap: () => context.push('/shop/${shop.id}'),
                      ),
                      onTap: () => context.push('/shop/${shop.id}'),
                    );
                  }).toSet(),
                ),
                / Professional Search/Filter Bar
                Positioned(
                  top: 60,
                  left: 20,
                  right: 20,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Find stores, services...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune, color: theme.colorScheme.primary),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                / User Location Button
                Positioned(
                  bottom: 100,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      mapController.animateCamera(CameraUpdate.newLatLng(_initialPosition));
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),
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
}
