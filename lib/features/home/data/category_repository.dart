import 'package:dio/dio.dart';
import '../domain/models/category.dart';

class CategoryRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:5000/api',
  ));

  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
}
