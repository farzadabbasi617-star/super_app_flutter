import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProducts;

  ProductBloc({required this.getProducts}) : super(ProductInitial()) {
    on<LoadProductsRequested>((event, emit) async {
      emit(ProductLoading());
      final result = await getProducts.execute(category: event.category, query: event.query);
      result.fold(
        (failure) => emit(ProductFailure(failure.message)),
        (products) => emit(ProductLoaded(products: products, categories: [], selectedCategory: event.category)),
      );
    });

    on<CategoryChanged>((event, emit) async {
      emit(ProductLoading());
      final result = await getProducts.execute(category: event.category);
      result.fold(
        (failure) => emit(ProductFailure(failure.message)),
        (products) => emit(ProductLoaded(products: products, categories: [], selectedCategory: event.category)),
      );
    });
  }
}
