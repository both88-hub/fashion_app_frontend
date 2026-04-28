import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_app/core/router/app_router.dart';
import '../providers/cart_provider.dart';
import '../../domain/models/cart_item.dart';

class CartScreen extends ConsumerWidget {
  final VoidCallback? onStartShopping;
  const CartScreen({super.key, this.onStartShopping});

  Color _getColorFromHex(String hex) {
    try {
      String cleanHex = hex;
      final match = RegExp(r'\((0x[0-9A-Fa-f]{8}|#[0-9A-Fa-f]{6})\)').firstMatch(hex);
      if (match != null) cleanHex = match.group(1)!;
      if (cleanHex.startsWith('#')) cleanHex = cleanHex.replaceFirst('#', '0xFF');
      return Color(int.parse(cleanHex));
    } catch (e) {
      return Colors.black;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Are you sure you want to remove this item from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).removeFromCart(index);
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
    const shipping = 15.00;
    final total = subtotal + shipping;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'My Cart',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(width: 12),
            if (cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${cartItems.length}',
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
      body: cartItems.isEmpty ? _buildEmptyState(context) : _buildCartList(cartItems, ref),
      bottomNavigationBar: cartItems.isEmpty ? null : _buildOrderSummary(context, subtotal, shipping, total),
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
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Cart Is Empty!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added anything to your cart yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            if (onStartShopping != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStartShopping,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Start Shopping', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList(List<CartItem> cartItems, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return Dismissible(
          key: Key('${item.product.id}_${item.selectedSize}_${item.selectedColor}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.red),
          ),
          onDismissed: (direction) => ref.read(cartProvider.notifier).removeFromCart(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Builder(
                    builder: (context) {
                      final imageUrl = item.product.imageUrl;
                      final isAsset = imageUrl.startsWith('assets/');
                      
                      // Helper to build the base image (either asset or network)
                      Widget buildBaseImage({double? width, double? height}) {
                        return isAsset
                            ? Image.asset(imageUrl, width: width, height: height, fit: BoxFit.cover)
                            : Image.network(
                                imageUrl,
                                width: width,
                                height: height,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: width,
                                  height: height,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              );
                      }

                      if (item.selectedColor.isNotEmpty && isAsset) {
                        // Only try color-specific assets if the base is an asset
                        final colorAssetName = 'assets/images/product${item.product.id}_${item.selectedColor}.png';
                        return Image.asset(
                          colorAssetName,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                  _getColorFromHex(item.selectedColor).withOpacity(0.4),
                                  BlendMode.modulate,
                                ),
                              child: buildBaseImage(width: 80, height: 80),
                            );
                          },
                        );
                      } else {
                        // Just show the base image, but with color filter if needed
                        if (item.selectedColor.isNotEmpty) {
                          return ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                _getColorFromHex(item.selectedColor).withOpacity(0.4),
                                BlendMode.modulate,
                              ),
                            child: buildBaseImage(width: 80, height: 80),
                          );
                        }
                        return buildBaseImage(width: 80, height: 80);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => _showDeleteConfirmation(context, ref, index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Size: ${item.selectedSize}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          if (item.selectedColor.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Text('Color:', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            const SizedBox(width: 4),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getColorFromHex(item.selectedColor),
                                border: Border.all(color: Colors.grey[300]!, width: 1),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${item.product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16),
                                  onPressed: () => ref.read(cartProvider.notifier).updateQuantity(index, item.quantity - 1),
                                ),
                                Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16),
                                  onPressed: () => ref.read(cartProvider.notifier).updateQuantity(index, item.quantity + 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(BuildContext context, double subtotal, double shipping, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(color: Colors.grey, fontSize: 16)),
                Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shipping', style: TextStyle(color: Colors.grey, fontSize: 16)),
                Text('\$${shipping.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(thickness: 1.5, color: Colors.black),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pushNamed(AppRoute.checkout.name),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Go to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
