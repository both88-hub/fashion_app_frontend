import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/product.dart';
import '../../data/product_repository.dart';

// Create the repository provider
final productRepositoryProvider = Provider((ref) => ProductRepository());

// Create a notifier to manage the products state
class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository _repository;

  ProductNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _repository.getAllProducts();
      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// The products provider that the UI will use
final productsProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductNotifier(repository);
});
