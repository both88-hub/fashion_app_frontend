import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_app/core/router/app_router.dart';
import 'package:fashion_app/features/home/presentation/screens/search_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/saved_items_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/cart_screen.dart';
import 'package:fashion_app/features/home/presentation/screens/account_screen.dart';
import 'package:fashion_app/shared/widgets/product_card.dart';
import 'package:fashion_app/features/home/presentation/providers/products_provider.dart';
import 'package:fashion_app/features/home/presentation/providers/nav_provider.dart';
import 'package:fashion_app/features/home/presentation/providers/cart_provider.dart';
import 'package:fashion_app/features/home/presentation/providers/categories_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Home tab state
  int _bannerIndex = 0;
  final PageController _bannerController = PageController();
  final ScrollController _scrollController = ScrollController();
  Timer? _bannerTimer;
  final List<String> _categories = ['All', 'T-Shirts', 'Jackets', 'Pants', 'Shoes', 'Accessories'];
  int _selectedCategoryIndex = 0;
  
  // Location dropdown state
  String _selectedLocation = 'Chbar Ampov';
  final List<String> _locations = ['Chbar Ampov', 'Ta Khmau', 'BBK'];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerIndex < 2) {
        _bannerIndex++;
      } else {
        _bannerIndex = 0;
      }
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _bannerIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuart,
        );
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() {});
  }

  // Filter state
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _selectedSortBy = 'Relevance';
  String _selectedSize = 'M';

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Sort By
              const Text(
                'Sort By',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Relevance', 'Price: Low - High', 'Price: High - Low'].map((option) {
                    final isSelected = _selectedSortBy == option;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setModalState(() => _selectedSortBy = option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // Price Range
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000,
                divisions: 100,
                labels: RangeLabels(
                  '\$${_priceRange.start.round()}',
                  '\$${_priceRange.end.round()}',
                ),
                activeColor: Colors.black,
                inactiveColor: Colors.grey[200],
                onChanged: (values) {
                  setModalState(() => _priceRange = values);
                  setState(() {}); // Sync to parent if needed
                },
              ),
              const SizedBox(height: 32),

              // Size
              const Text(
                'Size',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: ['S', 'M', 'L', 'XL', 'XXL'].map((size) {
                  final isSelected = _selectedSize == size;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => setModalState(() => _selectedSize = size),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            size,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    
    final List<Widget> pages = [
      _buildHomeBody(),
      const SearchScreen(),
      SavedItemsScreen(onDiscoverPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 0),
      const CartScreen(), // Refactored CartScreen
      const AccountScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: currentIndex == 0 
        ? AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const Icon(Icons.location_on_outlined, color: Colors.black),
            titleSpacing: 0,
            title: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLocation,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedLocation = newValue;
                    });
                  }
                },
                items: _locations.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: Colors.black),
                onPressed: () => context.pushNamed(AppRoute.notifications.name),
              ),
              const SizedBox(width: 8),
            ],
          )
        : null,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0 && currentIndex == 0) {
            // Tapped home while already on home: Reset filters and scroll to top
            setState(() {
              _selectedCategoryIndex = 0;
              _priceRange = const RangeValues(0, 1000);
              _selectedSortBy = 'Relevance';
              _selectedSize = 'M';
            });
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${ref.watch(wishlistProvider).length}'),
              isLabelVisible: ref.watch(wishlistProvider).isNotEmpty,
              backgroundColor: Colors.black,
              child: const Icon(Icons.favorite_border),
            ),
            activeIcon: Badge(
              label: Text('${ref.watch(wishlistProvider).length}'),
              isLabelVisible: ref.watch(wishlistProvider).isNotEmpty,
              backgroundColor: Colors.black,
              child: const Icon(Icons.favorite),
            ),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${ref.watch(cartProvider).length}'),
              isLabelVisible: ref.watch(cartProvider).isNotEmpty,
              backgroundColor: Colors.black,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              label: Text('${ref.watch(cartProvider).length}'),
              isLabelVisible: ref.watch(cartProvider).isNotEmpty,
              backgroundColor: Colors.black,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Colors.black,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Search Bar (Bonus for usability - links to Search Tab)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey, size: 22),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Search for clothes...',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                            Icon(Icons.mic_none_outlined, color: Colors.grey, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Banner Carousel
            SizedBox(
              height: 200,
              child: PageView(
                controller: _bannerController,
                onPageChanged: (index) => setState(() => _bannerIndex = index),
                children: [
                  _buildBannerCard('Summer Collection', 'Up to 50% OFF', 'assets/images/product5.png'),
                  _buildBannerCard('New Arrivals', 'Explore Now', 'assets/images/product6.png'),
                  _buildBannerCard('Free Shipping', 'On orders over \$50', 'assets/images/product8.png'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildDotIndicator(index)),
            ),
            const SizedBox(height: 24),

            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
                    child: const Text('See All', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(categoriesProvider);
                
                return categoriesAsync.when(
                  loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (categoryList) {
                    final displayCategories = ['All', ...categoryList.map((c) => c.name)];
                    
                    return SizedBox(
                      height: 40,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: displayCategories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedCategoryIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(displayCategories[index]),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) setState(() => _selectedCategoryIndex = index);
                              },
                              selectedColor: Colors.black,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), 
                                side: BorderSide(color: isSelected ? Colors.black : Colors.grey[300]!)
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Featured Products
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Featured Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
                    child: const Text('See All', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Product Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Consumer(
                builder: (context, ref, child) {
                  final productsAsync = ref.watch(productsProvider);
                  final categoriesAsync = ref.watch(categoriesProvider);
                  
                  return productsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (allProducts) {
                      return categoriesAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (categoryList) {
                          final displayCategories = ['All', ...categoryList.map((c) => c.name)];
                          final selectedCategoryName = displayCategories[_selectedCategoryIndex];
                          
                          var products = selectedCategoryName == 'All' 
                              ? allProducts 
                              : allProducts.where((p) => 
                                  p.parentCategory.toLowerCase() == selectedCategoryName.toLowerCase() || 
                                  p.category.toLowerCase() == selectedCategoryName.toLowerCase()
                                ).toList();

                          // Apply Price Filter
                          products = products.where((p) => 
                            p.price >= _priceRange.start && p.price <= _priceRange.end
                          ).toList();

                          // Only apply size filter if it's not the default 'M' or if the product has that size
                          // This prevents hiding numerical sized products (shoes) when M is selected by default
                          if (_selectedSize != 'M') {
                            products = products.where((p) => p.sizes.contains(_selectedSize)).toList();
                          }

                          // Apply Sort Order
                          if (_selectedSortBy == 'Price: Low - High') {
                            products = List.from(products)..sort((a, b) => a.price.compareTo(b.price));
                          } else if (_selectedSortBy == 'Price: High - Low') {
                            products = List.from(products)..sort((a, b) => b.price.compareTo(a.price));
                          }

                          if (products.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'No products found matching filters',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 24,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return ProductCard(
                                product: products[index],
                                heroTag: 'featured_product_${products[index].id}',
                              );
                            },
                          );
                        }
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard(String title, String subtitle, String imageUrl) {
    final imageProvider = imageUrl.startsWith('assets/') 
        ? AssetImage(imageUrl) as ImageProvider
        : NetworkImage(imageUrl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    final isSelected = _bannerIndex == index;
    return GestureDetector(
      onTap: () {
        _bannerController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isSelected ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
