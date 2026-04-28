import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:5000/api',
    validateStatus: (status) => status! < 500, // Don't throw for 4xx errors
  ));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _handleError(Response? response) {
    if (response?.data != null && response?.data is Map) {
      return response?.data['error'] ?? 'An unexpected error occurred';
    }
    return 'Server error (${response?.statusCode})';
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'last_email', value: email);
        return response.data;
      } else {
        throw Exception(_handleError(response));
      }
    } on DioException catch (e) {
      throw Exception('Connection failed. Please check your internet.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
      });

      if (response.statusCode == 201) {
        final token = response.data['token'];
        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'last_email', value: email);
        return response.data;
      } else {
        throw Exception(_handleError(response));
      }
    } on DioException catch (e) {
      throw Exception('Connection failed. Please check your internet.');
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<String?> getLastEmail() async {
    return await _storage.read(key: 'last_email');
  }

  Future<void> saveUserLocally(Map<String, dynamic> user) async {
    final userJson = jsonEncode(user);
    await _storage.write(key: 'user_data', value: userJson);
  }

  Future<Map<String, dynamic>?> getLocalUser() async {
    final userJson = await _storage.read(key: 'user_data');
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearLocalUser() async {
    await _storage.delete(key: 'user_data');
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No token found');

      final response = await _dio.get('/auth/me', options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(_handleError(response));
      }
    } on DioException catch (e) {
      throw Exception('Connection failed. Please check your internet.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await clearLocalUser();
  }
}
