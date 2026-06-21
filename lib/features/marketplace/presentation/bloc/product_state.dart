import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';

abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<Category> categories;
  final String? selectedCategory;
  ProductLoaded({
    required this.products,
    required this.categories,
    this.selectedCategory,
  });
  @override
  List<Object?> get props => [products, categories, selectedCategory];
}

class ProductFailure extends ProductState {
  final String error;
  ProductFailure(this.error);
  @override
  List<Object?> get props => [error];
}
