import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_app/core/router/app_router.dart';

class PaymentCardModel {
  final String id;
  final String brand;
  final String lastFour;
  final String expiry;
  final IconData icon;

  PaymentCardModel({
    required this.id,
    required this.brand,
    required this.lastFour,
    required this.expiry,
    required this.icon,
  });
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final List<PaymentCardModel> _cards = [
    PaymentCardModel(
      id: '1',
      brand: 'Visa',
      lastFour: '4582',
      expiry: '12/26',
      icon: Icons.credit_card,
    ),
    PaymentCardModel(
      id: '2',
      brand: 'Mastercard',
      lastFour: '8821',
      expiry: '09/25',
      icon: Icons.credit_card,
    ),
    PaymentCardModel(
      id: '3',
      brand: 'Apple Pay',
      lastFour: 'Pay',
      expiry: 'Primary',
      icon: Icons.apple,
    ),
  ];

  String _selectedCardId = '1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Payment Method',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                final isSelected = _selectedCardId == card.id;

                return RepaintBoundary(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black.withOpacity(0.02) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: RadioListTile<String>(
                      value: card.id,
                      groupValue: _selectedCardId,
                      onChanged: (val) => setState(() => _selectedCardId = val!),
                      activeColor: Colors.black,
                      title: Row(
                        children: [
                          Icon(card.icon, size: 24, color: Colors.black),
                          const SizedBox(width: 12),
                          Text(
                            '${card.brand} **** ${card.lastFour}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 36),
                        child: Text(
                          'Expires ${card.expiry}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.pushNamed(AppRoute.addNewCard.name),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text('Add New Card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
