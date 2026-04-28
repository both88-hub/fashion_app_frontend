import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_app/core/router/app_router.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _promoController = TextEditingController();
  int _selectedPaymentMethod = 0;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final cartItems = ref.watch(cartProvider);
      final subtotal = cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
      const shipping = 80.00;
      final total = subtotal + shipping;

      final addressState = ref.watch(addressProvider);
      final _currentAddress = addressState.selectedAddress;

      final screenWidth = MediaQuery.of(context).size.width;
      final paymentOptionWidth = (screenWidth - 40 - 24) / 3;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.notifications_none_outlined, color: Colors.black), onPressed: () {}),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Address Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => context.pushNamed(AppRoute.address.name),
                    child: const Text('Change', style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline, fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Address Card
              Container(
                decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.location_on_outlined, color: Colors.black, size: 20),
                  ),
                  title: Text(_currentAddress?.name ?? 'Home', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(
                    _currentAddress != null 
                        ? '${_currentAddress!.street}\n${_currentAddress!.city}, ${_currentAddress!.country}' 
                        : '925 S Chugach St #APT 10, Alaska 99645', 
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  onTap: () {
                    context.pushNamed(AppRoute.address.name);
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Payment Method Header
              const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Payment Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPaymentOption(0, 'Card', paymentOptionWidth),
                  _buildPaymentOption(1, 'Cash', paymentOptionWidth),
                  _buildPaymentOption(2, 'Pay', paymentOptionWidth),
                ],
              ),
              const SizedBox(height: 16),
              // Selected Card Preview
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: const Text('VISA', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18, fontStyle: FontStyle.italic)),
                  title: const Text('**** **** **** 2512', style: TextStyle(fontSize: 16, letterSpacing: 2)),
                  trailing: const Icon(Icons.edit_outlined, size: 20),
                  onTap: () => context.pushNamed(AppRoute.payment.name),
                ),
              ),
              const SizedBox(height: 32),
              // Order Summary Header
              const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _summaryRow('Sub-total', subtotal),
              _summaryRow('VAT (%)', 0.0),
              _summaryRow('Shipping fee', shipping),
              const Divider(height: 32, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 32),
              // Promo Code
              Row(
                children: [
                  SizedBox(
                    width: screenWidth - 40 - 110, // Remaining width for text field
                    child: TextField(
                      controller: _promoController,
                      decoration: InputDecoration(
                        hintText: 'Enter promo code',
                        prefixIcon: const Icon(Icons.local_offer_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF8F8F8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 98,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Placed!')));
                    ref.read(cartProvider.notifier).clearCart();
                    context.goNamed(AppRoute.orderSuccess.name);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Place Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text('ERROR: $e', style: const TextStyle(color: Colors.red))),
      );
    }
  }

  Widget _buildPaymentOption(int index, String label, double width) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _selectedPaymentMethod == index ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _selectedPaymentMethod == index ? Colors.black : Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: _selectedPaymentMethod == index ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text('\$${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
