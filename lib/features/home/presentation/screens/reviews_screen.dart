import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_app/core/router/app_router.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final List<Map<String, dynamic>> _reviews = List.generate(
    5,
    (index) => {
      'name': 'User ${index + 1}',
      'initials': 'U${index + 1}',
      'date': '24 Apr 2024',
      'rating': 5,
      'comment': 'The quality of this product is absolutely amazing. It fits perfectly and the fabric feels very premium.',
    },
  );

  bool _isLoadingMore = false;

  void _loadMore() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _reviews.addAll(List.generate(
        3,
        (index) => {
          'name': 'New User ${index + 1}',
          'initials': 'NU',
          'date': '25 Apr 2024',
          'rating': 4,
          'comment': 'Great product! Will definitely buy again in different colors.',
        },
      ));
      _isLoadingMore = false;
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
          'Reviews (4.8)',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildRatingSummary(),
            const Divider(height: 1),
            _buildReviewList(),
            if (_reviews.length < 15)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _isLoadingMore
                    ? const CircularProgressIndicator(color: Colors.black)
                    : OutlinedButton(
                        onPressed: _loadMore,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Load More', style: TextStyle(color: Colors.black)),
                      ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildWriteReviewButton(),
    );
  }

  Widget _buildRatingSummary() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Column(
            children: [
              const Text(
                '4.8',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                ),
              ),
              const SizedBox(height: 4),
              Text('124 Reviews', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.9),
                _buildRatingBar(4, 0.1),
                _buildRatingBar(3, 0.05),
                _buildRatingBar(2, 0.02),
                _buildRatingBar(1, 0.01),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int rating, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text('$rating', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey[100],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: _reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 32),
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Text(
                      review['initials'],
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(review['date'], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(
                      review['rating'],
                      (index) => const Icon(Icons.star, color: Colors.amber, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                review['comment'],
                style: TextStyle(color: Colors.grey[700], height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWriteReviewButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: ElevatedButton(
        onPressed: () => context.pushNamed(AppRoute.leaveReview.name),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Write a Review', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
