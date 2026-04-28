import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_app/features/profile/presentation/providers/profile_providers.dart';

class FaqsScreen extends ConsumerWidget {
  const FaqsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredFaqs = ref.watch(filteredFaqsProvider);
    final categories = filteredFaqs.map((e) => e.category).toSet().toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('FAQs'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (val) => ref.read(faqSearchProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search for questions...',
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // FAQ List
          Expanded(
            child: filteredFaqs.isEmpty
                ? const Center(child: Text('No FAQs found matching your search.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final categoryFaqs = filteredFaqs.where((f) => f.category == category).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          ...categoryFaqs.map((faq) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    faq.question,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    side: BorderSide.none,
                                  ),
                                  collapsedShape: const RoundedRectangleBorder(
                                    side: BorderSide.none,
                                  ),
                                  iconColor: Colors.black,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                      child: Text(
                                        faq.answer,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
