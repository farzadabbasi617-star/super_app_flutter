import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/shop.dart';
import '../../domain/usecases/get_nearby_shops_usecase.dart';
import '../../domain/usecases/get_shop_details_usecase.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetNearbyShopsUseCase getNearbyShops;
  final GetShopDetailsUseCase getShopDetails;

  MapBloc({required this.getNearbyShops, required this.getShopDetails})
      : super(MapLoaded([
          const Shop(
            id: 's1',
            name: 'Tech Hub',
            description: 'Premium electronics and gadget repair center.',
            location: LatLng(35.6892, 51.3890),
            imageUrl:
                'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=150',
            category: 'Electronics',
            rating: 4.8,
            reviewCount: 124,
            address: 'Tehran, Valiasr St, Block 4',
            phoneNumber: '+982188776655',
            website: 'techhub.ir',
            isOpen: true,
            operatingHours: '۰۹:۰۰ الی ۲۲:۰۰',
          ),
          const Shop(
            id: 's2',
            name: 'Green Garden',
            description: 'Organic plants and landscape design.',
            location: LatLng(35.6950, 51.3950),
            imageUrl:
                'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?w=150',
            category: 'Plants',
            rating: 4.5,
            reviewCount: 89,
            address: 'Tehran, Niavaran Ave, G1',
            phoneNumber: '+982122334455',
            website: 'greengarden.ir',
            isOpen: true,
            operatingHours: '۰۸:۰۰ الی ۲۰:۰۰',
          ),
          const Shop(
            id: 's3',
            name: 'Coffee Corner',
            description: 'Specialty coffee and artisan pastries.',
            location: LatLng(35.6800, 51.3700),
            imageUrl:
                'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=150',
            category: 'Cafe',
            rating: 4.9,
            reviewCount: 210,
            address: 'Tehran, Jordan St, C2',
            phoneNumber: '+982122022211',
            website: 'coffeecorner.ir',
            isOpen: false,
            operatingHours: '۰۷:۰۰ الی ۲۳:۰۰',
          ),
          const Shop(
            id: 's6',
            name: 'کلینیک درمانی آریا',
            description: 'In-Clinic treatment, GP, dressings and family health.',
            location: LatLng(35.6810, 51.3910),
            imageUrl:
                'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=150',
            category: 'Clinic',
            rating: 4.8,
            reviewCount: 154,
            address: 'تهران، میدان ونک، بن‌بست آریا، پلاک ۱۲',
            phoneNumber: '+982188999900',
            website: 'ariaclinic.ir',
            isOpen: true,
            operatingHours: '۰۸:۰۰ الی ۲۱:۰۰',
          ),
          const Shop(
            id: 's9',
            name: 'کباب‌سرای زعفران',
            description: 'Traditional Persian kebab house.',
            location: LatLng(35.6830, 51.3750),
            imageUrl:
                'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=150',
            category: 'Restaurant',
            rating: 4.8,
            reviewCount: 320,
            address: 'تهران، خیابان ولیعصر، نرسیده به باغ فردوس، پلاک ۱۴',
            phoneNumber: '+982122042205',
            website: 'zafrankebab.ir',
            isOpen: true,
            operatingHours: '۱۲:۰۰ الی ۲۴:۰۰',
          ),
        ])) {
    on<LoadNearbyShopsRequested>((event, emit) async {
      final result = await getNearbyShops.execute(event.userLocation);
      result.fold(
        (failure) => null,
        (shops) => emit(MapLoaded(shops)),
      );
    });

    on<ShopSelected>((event, emit) async {});
  }
}
