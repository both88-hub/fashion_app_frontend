import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/product.dart';
import '../../domain/models/cart_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart({
    required Product product,
    required String selectedSize,
    required String selectedColor,
    required int quantity,
  }) {
    // Check if item already exists with same size and color
    final existingIndex = state.indexWhere((item) =>
        item.product.id == product.id &&
        item.selectedSize == selectedSize &&
        item.selectedColor == selectedColor);

    if (existingIndex != -1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            CartItem(
              product: state[i].product,
              selectedSize: state[i].selectedSize,
              selectedColor: state[i].selectedColor,
              quantity: state[i].quantity + quantity,
            )
          else
            state[i],
      ];
    } else {
      state = [
        ...state,
        CartItem(
          product: product,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
          quantity: quantity,
        ),
      ];
    }
  }

  void removeFromCart(int index) {
    state = [...state]..removeAt(index);
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity < 1) return;
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          CartItem(
            product: state[i].product,
            selectedSize: state[i].selectedSize,
            selectedColor: state[i].selectedColor,
            quantity: newQuantity,
          )
        else
          state[i],
    ];
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class WishlistNotifier extends StateNotifier<List<String>> {
  WishlistNotifier() : super([]);

  void toggle(String productId) {
    if (state.contains(productId)) {
      state = state.where((id) => id != productId).toList();
    } else {
      state = [...state, productId];
    }
  }

  bool contains(String productId) => state.contains(productId);
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<String>>((ref) {
  return WishlistNotifier();
});
