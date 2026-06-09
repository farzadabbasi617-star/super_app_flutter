import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<LoadProductsRequested>((event, emit) async {
      emit(ProductLoading());
      try {
        final categories = await productRepository.getCategories();
        final products = await productRepository.getProducts(category: event.category, query: event.query);
        emit(ProductLoaded(products: products, categories: categories, selectedCategory: event.category));
      } catch (e) {
        emit(ProductFailure(e.toString()));
      }
    });

    on<CategoryChanged>((event, emit) async {
      emit(ProductLoading());
      try {
        final categories = await productRepository.getCategories();
        final products = await productRepository.getProducts(category: event.category);
        emit(ProductLoaded(products: products, categories: categories, selectedCategory: event.category));
      } catch (e) {
        emit(ProductFailure(e.toString()));
      }
    });
  }
}
