import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import 'shop_detail_page.dart';
import 'package:go_router/go_router.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = const LatLng(35.6892, 51.3890);

  @override
  void initState() {
    super.initState();
    // Load shops on start
    context.read<MapBloc>().add(LoadNearbyShopsRequested(_initialPosition));
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
                  initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 14),
                  onMapCreated: (controller) => mapController = controller,
                  markers: state.shops.map((shop) {
                    return Marker(
                      markerId: MarkerId(shop.id),
                      position: shop.location,
                      infoWindow: InfoWindow(
                        title: shop.name,
                        onTap: () => context.push('/shop/${shop.id}'),
                      ),
                      onTap: () => context.push('/shop/${shop.id}'),
                    );
                  }).toSet(),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Explore stores around you',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (state is MapFailure) {
            return Center(child: Text('Error: ${state.error}'));
          }
          return const Center(child: Text('Initialize map...'));
        },
      ),
    );
  }
}
