import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.220.229:8000/api";

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/auth/login/");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Access token or user info
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data: ${response.body}");
    }
  }

  Future<List<Map<String, dynamic>>> fetchExperts() async {
  final url = Uri.parse("$baseUrl/experts");
  final response = await http.get(
    url,
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) {
      return {
        ...item as Map<String, dynamic>,
        // Ensure 'categories' is a List<int>
        'categories': (item['categories'] as List<dynamic>).map((e) => e as int).toList(),
      };
    }).toList();
  } else {
    throw Exception("Failed to load experts: ${response.body}");
  }
}


}