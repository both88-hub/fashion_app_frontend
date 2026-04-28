import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_app/features/profile/presentation/providers/profile_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSwitchTile(
            title: 'Order Updates',
            subtitle: 'Get notified about your order status and delivery',
            value: settings.orderUpdates,
            onChanged: (val) => notifier.toggleOrderUpdates(val),
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Promotions & Offers',
            subtitle: 'Stay updated with latest sales and discount coupons',
            value: settings.promotions,
            onChanged: (val) => notifier.togglePromotions(val),
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'New Arrivals',
            subtitle: 'Be the first to know when new collections arrive',
            value: settings.newArrivals,
            onChanged: (val) => notifier.toggleNewArrivals(val),
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Price Drops',
            subtitle: 'Get alerts when items in your wishlist drop in price',
            value: settings.priceDrops,
            onChanged: (val) => notifier.togglePriceDrops(val),
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'App Updates',
            subtitle: 'Important notifications about new app features',
            value: settings.appUpdates,
            onChanged: (val) => notifier.toggleAppUpdates(val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.black,
        activeTrackColor: Colors.grey[300],
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[100],
      thickness: 1,
      indent: 28,
      endIndent: 28,
    );
  }
}
