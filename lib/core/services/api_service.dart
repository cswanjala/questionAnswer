import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:question_nswer/core/constants/api_constants.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: "auth_token");
  }

  Future<Response> get(String endpoint) async {
    final token = await _getToken();
    _dio.options.headers["Authorization"] = "Bearer $token";
    return await _dio.get(endpoint);
  }

  Future<Response> post(String endpoint, Map<String, dynamic> data, {bool requiresAuth = true}) async {
    if (requiresAuth) {
      final token = await _getToken();
      _dio.options.headers["Authorization"] = "Bearer $token";
    }
    return await _dio.post(endpoint, data: data);
  }

  Future<void> saveToken(String token, String userId) async {
    await _storage.write(key: "auth_token", value: token);
    await _storage.write(key: "user_id", value: userId);
  }

  // Fetch categories
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final response = await _dio.get(ApiConstants.categoriesEndpoint);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Submit question
  Future<void> submitQuestion(String questionContent, String token, int categoryId) async {
    try {
      final response = await _dio.post(
        ApiConstants.questionsEndpoint,
        data: {
          'content': questionContent,
          'category': categoryId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to submit question');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Fetch experts
  Future<List<Map<String, dynamic>>> fetchExperts() async {
    try {
      final token = await _storage.read(key: ApiConstants.authTokenKey);
      if (token == null) {
        throw Exception('Auth token is missing');
      }

      final response = await _dio.get(
        '/experts', // Your API endpoint to fetch experts
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Add Bearer token if needed
          },
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load experts');
      }
    } catch (e) {
      throw Exception('Error fetching experts: $e');
    }
  }
}

