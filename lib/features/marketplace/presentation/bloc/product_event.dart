import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProductsRequested extends ProductEvent {
  final String? category;
  final String? query;
  LoadProductsRequested({this.category, this.query});
  @override
  List<Object?> get props => [category, query];
}

class CategoryChanged extends ProductEvent {
  final String category;
  CategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}
