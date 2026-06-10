import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/entities/category.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProducts;
  final GetCategoriesUseCase getCategories;

  ProductBloc({
    required this.getProducts,
    required this.getCategories,
  }) : super(ProductInitial()) {
    
    on<LoadProductsRequested>((event, emit) async {
      emit(ProductLoading());
      
      final categoriesResult = await getCategories.execute();
      final productsResult = await getProducts.execute(category: event.category, query: event.query);
      
      categoriesResult.fold(
        (failure) => emit(ProductFailure(failure.message)),
        (categories) {
          productsResult.fold(
            (failure) => emit(ProductFailure(failure.message)),
            (products) => emit(ProductLoaded(
              products: products, 
              categories: categories, 
              selectedCategory: event.category,
            )),
          );
        },
      );
    });

    on<CategoryChanged>((event, emit) async {
      final currentState = state;
      List<Category> currentCategories = [];
      if (currentState is ProductLoaded) {
        currentCategories = currentState.categories;
      } else {
        final categoriesResult = await getCategories.execute();
        categoriesResult.fold((_) => null, (cats) => currentCategories = cats);
      }

      emit(ProductLoading());
      final result = await getProducts.execute(category: event.category);
      result.fold(
        (failure) => emit(ProductFailure(failure.message)),
        (products) => emit(ProductLoaded(
          products: products, 
          categories: currentCategories, 
          selectedCategory: event.category,
        )),
      );
    });
  }
}
