import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isRental;
  final double rentalPricePerDay;
  final List<DateTime> unavailableDates;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isRental = false,
    this.rentalPricePerDay = 0.0,
    this.unavailableDates = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        category,
        isRental,
        rentalPricePerDay,
        unavailableDates,
      ];
}
