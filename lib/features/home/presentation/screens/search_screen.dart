import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_app/shared/widgets/product_card.dart';
import 'package:fashion_app/features/home/presentation/widgets/filter_bottom_sheet.dart';
import 'package:fashion_app/features/home/presentation/providers/nav_provider.dart';
import 'package:fashion_app/features/home/presentation/providers/products_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_app/core/router/app_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isTyping = false;
  int _activeFiltersCount = 0;

  final List<String> _recentSearches = ['Winter Jacket', 'Leather Boots', 'Cotton T-Shirt', 'Denim Jeans'];
  final List<String> _popularCategories = ['New Arrivals', 'Best Sellers', 'Discount', 'Collections', 'Limited Edition'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _isTyping = value.isNotEmpty;
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Recommended', true),
              _buildSortOption('Newest Arrivals', false),
              _buildSortOption('Price: Low to High', false),
              _buildSortOption('Price: High to Low', false),
              _buildSortOption('Popularity', false),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
    
    if (result != null) {
      setState(() => _activeFiltersCount = result);
    }
  }

  Widget _buildSortOption(String label, bool isSelected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.black : Colors.grey[600],
      )),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.black) : null,
      onTap: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _isTyping ? _buildSearchResults() : _buildDefaultView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer(
                builder: (context, ref, child) => IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    ref.read(bottomNavIndexProvider.notifier).state = 0;
                  },
                ),
              ),
              const Text(
                'Search',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: Colors.black),
                onPressed: () => context.pushNamed(AppRoute.notifications.name),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search for clothes...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.black),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          ),
                        const Icon(Icons.mic_none_outlined, color: Colors.grey),
                        const SizedBox(width: 12),
                      ],
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                ),
              ),
              if (_isTyping)
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                    FocusScope.of(context).unfocus();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Recent Searches
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => setState(() => _recentSearches.clear()),
                child: const Text('Clear All', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._recentSearches.map((query) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(query, style: const TextStyle(color: Colors.black87)),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () => setState(() => _recentSearches.remove(query)),
                ),
                onTap: () {
                  _searchController.text = query;
                  _onSearchChanged(query);
                },
              )),
          const SizedBox(height: 32),
          // Popular Categories
          const Text(
            'Popular Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _popularCategories
                .map((cat) => ActionChip(
                      label: Text(cat),
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      onPressed: () {
                        _searchController.text = cat;
                        _onSearchChanged(cat);
                        FocusScope.of(context).unfocus();
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
          const Text(
            'All Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final productsAsync = ref.watch(productsProvider);
              
              return productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (products) {
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
                        heroTag: 'discover_product_${products[index].id}',
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // Mocking an empty state if search is "xyz"
    if (_searchController.text.toLowerCase() == 'xyz') {
      return _buildEmptyResults();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '24 results for "${_searchController.text}"',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Row(
                children: [
                  // Filter Button with Badge
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: _showFilterOptions,
                      ),
                      if (_activeFiltersCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$_activeFiltersCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_vert),
                    onPressed: _showSortOptions,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final productsAsync = ref.watch(productsProvider);

              return productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (products) {
                  final filteredProducts = products.where((p) => 
                    p.name.toLowerCase().contains(_searchController.text.toLowerCase())
                  ).toList();

                  if (filteredProducts.isEmpty && _searchController.text.isNotEmpty) {
                    return _buildEmptyResults();
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: filteredProducts[index],
                        heroTag: 'search_product_${filteredProducts[index].id}',
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyResults() {
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
            child: Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          const Text(
            'No results found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or filters.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
