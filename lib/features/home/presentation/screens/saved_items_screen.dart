import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_app/shared/widgets/product_card.dart';
import 'package:fashion_app/features/home/presentation/providers/products_provider.dart';
import 'package:fashion_app/features/home/presentation/providers/cart_provider.dart';

class SavedItemsScreen extends ConsumerWidget {
  final VoidCallback onDiscoverPressed;
  const SavedItemsScreen({super.key, required this.onDiscoverPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final savedIds = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Saved Items',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            productsAsync.when(
              data: (products) {
                final savedCount = products.where((p) => savedIds.contains(p.id)).length;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$savedCount',
                    style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, __) => Center(child: Text('Error: $err')),
        data: (products) {
          final savedProducts = products.where((p) => savedIds.contains(p.id)).toList();
          if (savedProducts.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildSavedGrid(savedProducts, ref);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_outline, size: 80, color: Colors.red[200]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nothing saved yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on products to save them for later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDiscoverPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Discover Products', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedGrid(List savedProducts, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: savedProducts.length,
      itemBuilder: (context, index) {
        final product = savedProducts[index];
        return Stack(
          children: [
            ProductCard(
              product: product,
              heroTag: 'saved_product_${product.id}',
            ),
            // Heart icon remains red because it's in the saved list
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  ref.read(wishlistProvider.notifier).toggle(product.id);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
