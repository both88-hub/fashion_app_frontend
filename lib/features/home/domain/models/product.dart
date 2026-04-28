class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> images;
  final String category; // Sub-category name
  final String parentCategory; // Main category name (Woman, Man, etc.)
  final List<String> sizes;
  final List<String> colors;
  final List<String>? colorImages;
  final List<Review> reviews;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.images,
    required this.category,
    required this.parentCategory,
    required this.sizes,
    required this.colors,
    this.colorImages,
    required this.reviews,
  });

  static String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://placehold.co/600x800/png?text=No+Image';
    }
    
    if (url.startsWith('/uploads/')) {
      return 'http://10.0.2.2:5000$url';
    }
    
    String fixedUrl = url;
    if (fixedUrl.contains('localhost')) {
      fixedUrl = fixedUrl.replaceAll('localhost', '10.0.2.2');
    }
    
    if (!fixedUrl.startsWith('http') && !fixedUrl.startsWith('assets/')) {
       return 'https://placehold.co/600x800/png?text=Invalid+Image';
    }
    
    return fixedUrl;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final skus = json['skus'] as List? ?? [];
    final firstSku = skus.isNotEmpty ? skus[0] : {};
    
    double parsedPrice = 0.0;
    try {
      parsedPrice = double.parse(firstSku['price']?.toString() ?? '0.0');
    } catch (_) {}

    final coverUrl = _fixImageUrl(json['cover']);
    
    // Parse multiple images and ensure cover is first
    final List<dynamic> imagesJson = json['images'] as List? ?? [];
    final List<String> allImages = imagesJson.map((img) => _fixImageUrl(img.toString())).toList();
    
    // Put cover at the beginning if not already there
    if (!allImages.contains(coverUrl)) {
      allImages.insert(0, coverUrl);
    } else {
      // If it is there, move it to index 0
      allImages.remove(coverUrl);
      allImages.insert(0, coverUrl);
    }

    final allSizes = skus
        .map((sku) => sku['size_attribute']?['value']?.toString())
        .where((v) => v != null)
        .cast<String>()
        .toSet()
        .toList();
    
    final allColors = skus
        .map((sku) => sku['color_attribute']?['value']?.toString())
        .where((v) => v != null)
        .cast<String>()
        .toSet()
        .toList();

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      brand: 'Fashion App',
      price: parsedPrice,
      rating: 4.5,
      reviewCount: 10,
      imageUrl: coverUrl,
      images: allImages,
      category: json['sub_category']?['name'] ?? 'Other',
      parentCategory: json['sub_category']?['parent']?['name'] ?? 'All',
      sizes: allSizes.isEmpty ? ['S', 'M', 'L', 'XL'] : allSizes,
      colors: allColors.isEmpty ? ['#000000'] : allColors,
      colorImages: allImages,
      reviews: [
        Review(
          reviewer: 'Sokha Mean',
          comment: 'Perfect fit and very comfortable for running!',
          rating: 5.0,
          avatarUrl: 'https://i.pravatar.cc/150?u=sokha',
        ),
        Review(
          reviewer: 'Dara Samath',
          comment: 'The color is exactly as shown in the pictures.',
          rating: 4.0,
          avatarUrl: 'https://i.pravatar.cc/150?u=dara',
        ),
      ],
    );
  }
}

class Review {
  final String reviewer;
  final String comment;
  final double rating;
  final String avatarUrl;

  Review({
    required this.reviewer,
    required this.comment,
    required this.rating,
    required this.avatarUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewer: json['reviewer'] ?? '',
      comment: json['comment'] ?? '',
      rating: (json['rating'] ?? 5.0).toDouble(),
      avatarUrl: json['avatarUrl'] ?? 'https://ui-avatars.com/api/?name=${json['reviewer'] ?? 'User'}',
    );
  }
}
