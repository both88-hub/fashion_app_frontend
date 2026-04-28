import 'package:dio/dio.dart';
import '../domain/models/product.dart';

class ProductRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:5000/api',
  ));

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _dio.get('/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
}
