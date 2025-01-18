import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:question_nswer/core/constants/api_constants.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: "auth_token");
  }

  // Public method to expose the token indirectly
  Future<String?> getAuthToken() async {
    return await _getToken();
  }

  Future<Response> get(String endpoint) async {
    log("dio.get reached...");
    final token = await _getToken();
    _dio.options.headers["Authorization"] = "Bearer $token";
    return await _dio.get(endpoint);
  }

  Future<Response> post(String endpoint, dynamic data, {bool requiresAuth = true}) async {
    if (requiresAuth) {
      log("inside get response but from ApiService");
      final token = await _getToken();
      _dio.options.headers["Authorization"] = "Bearer $token";
      log("already done");
    }
    return await _dio.post(endpoint, data: data);
  }

  Future<Response> put(String endpoint, Map<String, dynamic> data, {bool requiresAuth = true}) async {
    if (requiresAuth) {
      final token = await _getToken();
      _dio.options.headers["Authorization"] = "Bearer $token";
    }
    return await _dio.put(endpoint, data: data);
  }

  Future<Response> delete(String endpoint, {bool requiresAuth = true}) async {
    if (requiresAuth) {
      final token = await _getToken();
      _dio.options.headers["Authorization"] = "Bearer $token";
    }
    return await _dio.delete(endpoint);
  }

  // Save token and user details, including username
  Future<void> saveToken(String token, String userId, String username) async {
    await _storage.write(key: "auth_token", value: token);
    await _storage.write(key: "user_id", value: userId);
    await _storage.write(key: "username", value: username);
  }

  // Retrieve user data including username
  Future<Map<String, String?>> getUserData() async {
    final userId = await _storage.read(key: "user_id");
    final authToken = await _getToken();
    final username = await _storage.read(key: "username");

    return {
      "user_id": userId,
      "auth_token": authToken,
      "username": username
    };
  }
}
