import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Shop extends Equatable {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final String imageUrl;
  final String category;
  final double rating;

  const Shop({
    required this.id, 
    required this.name, 
    required this.description, 
    required this.location, 
    required this.imageUrl, 
    required this.category, 
    required this.rating
  });

  @override
  List<Object?> get props => [id, name, description, location, imageUrl, category, rating];
}
