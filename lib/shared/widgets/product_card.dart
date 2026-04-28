import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_app/core/router/app_router.dart';
import 'package:fashion_app/features/home/domain/models/product.dart';
import 'package:fashion_app/features/home/presentation/providers/cart_provider.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final String? heroTag;

  const ProductCard({
    super.key,
    required this.product,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveTag = heroTag ?? 'product_${product.id}_${hashCode}';
    final isFavorite = ref.watch(wishlistProvider).contains(product.id);

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoute.productDetails.name,
          extra: product,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Hero(
                  tag: effectiveTag,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: product.imageUrl.startsWith('assets/')
                            ? AssetImage(product.imageUrl) as ImageProvider
                            : NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
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
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFavorite ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            product.brand,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
