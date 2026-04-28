import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationModel {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final bool isUnread;

  NotificationModel({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    this.isUnread = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      title: 'Order Delivered',
      subtitle: 'Your order #12345 has been successfully delivered.',
      time: '2m ago',
      icon: Icons.local_shipping_outlined,
      isUnread: true,
    ),
    NotificationModel(
      title: 'Flash Sale!',
      subtitle: 'Summer sale is live! Get up to 50% off on all items.',
      time: '1h ago',
      icon: Icons.sell_outlined,
      isUnread: true,
    ),
    NotificationModel(
      title: 'New Collection',
      subtitle: 'The 2024 Autumn collection is now available.',
      time: '3h ago',
      icon: Icons.style_outlined,
    ),
    NotificationModel(
      title: 'System Update',
      subtitle: 'We have improved the checkout experience for you.',
      time: '1d ago',
      icon: Icons.settings_outlined,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = NotificationModel(
          title: _notifications[i].title,
          subtitle: _notifications[i].subtitle,
          time: _notifications[i].time,
          icon: _notifications[i].icon,
          isUnread: false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _notifications.isEmpty ? _buildEmptyState() : _buildNotificationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_outlined, size: 80, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We will notify you when something arrives.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _notifications[index];
        return Container(
          decoration: BoxDecoration(
            color: item.isUnread ? Colors.blue.withOpacity(0.03) : Colors.transparent,
            border: item.isUnread
                ? const Border(left: BorderSide(color: Colors.blue, width: 4))
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: Colors.black, size: 24),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontWeight: item.isUnread ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                item.subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            trailing: Text(
              item.time,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}
