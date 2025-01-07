import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://192.168.220.229:8000/api"));
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?>_getToken() async {
    return await _storage.read(key: "auth_token");
  }

  Future<Response> get(String endpoint) async {
    final token = await _getToken();
    _dio.options.headers["Authorization"] = "Bearer $token";

    return await _dio.get(endpoint);
  }

  Future<Response> post(String endpoint,Map<String,dynamic> data) async {
    final token = await _getToken();
    _dio.options.headers["Authorization"] = "Bearer $token";
    return await _dio.post(endpoint,data: data);

  }
}