import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/category_repository.dart';
import '../../domain/models/category.dart';

final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getAllCategories();
});
