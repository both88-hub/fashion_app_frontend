import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_app/core/router/app_router.dart';

enum OrderStatus { active, completed, historyBuy }

class OrderModel {
  final String id;
  final String productName;
  final String imageUrl;
  final int quantity;
  final double price;
  final OrderStatus status;
  final String date;

  OrderModel({
    required this.id,
    required this.productName,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    required this.status,
    required this.date,
  });
}

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Completed', 'History Buy'];

  final List<OrderModel> _allOrders = [
    OrderModel(
      id: '1',
      productName: 'Premium Cotton T-Shirt',
      imageUrl: 'assets/images/product1.png',
      quantity: 1,
      price: 45.00,
      status: OrderStatus.active,
      date: '24 Apr 2024',
    ),
    OrderModel(
      id: '2',
      productName: 'Modern Wool Blazer',
      imageUrl: 'assets/images/product2.png',
      quantity: 1,
      price: 185.00,
      status: OrderStatus.completed,
      date: '20 Apr 2024',
    ),

    OrderModel(
      id: '3',
      productName: 'Linen Blend Trousers',
      imageUrl: 'assets/images/product3.png',
      quantity: 2,
      price: 59.90,
      status: OrderStatus.completed,
      date: '10 Apr 2024',
    ),
  ];

  List<OrderModel> get _filteredOrders {
    if (_selectedFilter == 'All') return _allOrders;
    final targetStatus = OrderStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == _selectedFilter.replaceAll(' ', '').toLowerCase(),
      orElse: () => OrderStatus.active,
    );
    return _allOrders.where((o) => o.status == targetStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) => _buildOrderTile(_filteredOrders[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = filter);
                }
              },
              backgroundColor: Colors.grey[50],
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? Colors.black : Colors.grey[200]!),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderTile(OrderModel order) {
    return GestureDetector(
      onTap: () {
        if (order.status == OrderStatus.active) {
          context.pushNamed(
            AppRoute.trackOrder.name,
            pathParameters: {'id': order.id},
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: order.imageUrl.startsWith('http')
                ? Image.network(
                    order.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    order.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
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
                    _buildStatusBadge(order.status),
                    Text(order.date, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${order.quantity} | \$${order.price.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Reorder', style: TextStyle(color: Colors.black, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String label;

    switch (status) {
      case OrderStatus.active:
        color = Colors.blue;
        label = 'Active';
        break;
      case OrderStatus.completed:
        color = Colors.green;
        label = 'Completed';
        break;
      case OrderStatus.historyBuy:
        color = Colors.purple;
        label = 'History Buy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'No $_selectedFilter Orders',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any orders in this category yet.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
