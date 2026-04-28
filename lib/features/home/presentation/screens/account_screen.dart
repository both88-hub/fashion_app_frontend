import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_app/core/router/app_router.dart';
import 'package:fashion_app/features/auth/providers/auth_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAuthenticated = authState.isAuthenticated;
    
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    final String firstName = user?['first_name'] ?? '';
    final String lastName = user?['last_name'] ?? '';
    final String fullName = (firstName.isEmpty && lastName.isEmpty) 
        ? (isAuthenticated ? (user?['username'] ?? 'User') : 'Guest User')
        : '$firstName $lastName';
        
    final email = user != null ? user['email'] : (isAuthenticated ? '' : 'Not logged in');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Account',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Header
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[100],
              backgroundImage: const NetworkImage('https://picsum.photos/seed/user123/200/200'),
            ),
            const SizedBox(height: 16),
            Text(
              fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
            const SizedBox(height: 32),
            
            // Menu Items (Locked for guests)
            _buildMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'My History',
              onTap: () => _handleProtectedAction(context, isAuthenticated, () => context.pushNamed(AppRoute.myOrders.name)),
            ),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'My Details',
              onTap: () => _handleProtectedAction(context, isAuthenticated, () => context.pushNamed(AppRoute.myDetails.name)),
            ),
            _buildMenuItem(
              icon: Icons.notifications_none_outlined,
              title: 'Notification Settings',
              onTap: () => _handleProtectedAction(context, isAuthenticated, () => context.pushNamed(AppRoute.notificationSettings.name)),
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'FAQs',
              onTap: () => context.pushNamed(AppRoute.faqs.name),
            ),
            _buildMenuItem(
              icon: Icons.support_agent_outlined,
              title: 'Help Center',
              onTap: () => context.pushNamed(AppRoute.helpCenter.name),
            ),
            
            const SizedBox(height: 32),
            
            // Auth Button (Login for guests, Logout for users)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                onTap: () => isAuthenticated ? _showLogoutDialog(context, ref) : context.pushNamed(AppRoute.auth.name),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isAuthenticated ? Colors.red[50] : Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAuthenticated ? Icons.logout : Icons.login, 
                    color: isAuthenticated ? Colors.red : Colors.black, 
                    size: 20,
                  ),
                ),
                title: Text(
                  isAuthenticated ? 'Logout' : 'Sign In',
                  style: TextStyle(
                    color: isAuthenticated ? Colors.red : Colors.black, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right, 
                  color: isAuthenticated ? Colors.red : Colors.black,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _handleProtectedAction(BuildContext context, bool isAuthenticated, VoidCallback action) {
    if (isAuthenticated) {
      action();
    } else {
      _showAuthRequiredDialog(context);
    }
  }

  void _showAuthRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Required'),
        content: const Text('Please sign in to access your personal details and order history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pushNamed(AppRoute.auth.name);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirm dialog
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              );

              await ref.read(authProvider.notifier).logout();

              if (context.mounted) {
                Navigator.pop(context); // Close loading dialog
                context.goNamed(AppRoute.home.name);
              }
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
