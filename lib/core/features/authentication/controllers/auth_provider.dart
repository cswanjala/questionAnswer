import 'package:flutter/material.dart';
import 'package:question_nswer/core/services/api_service.dart';

class AuthProvider with ChangeNotifier{
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String username,String password) async {
    try {
      final response = await _apiService.post("/login",{
        "username":username,
        "password":password,
      });
      _isAuthenticated = true;
      notifyListeners();
    } catch(e) {
      print("login error: $e");
    }

  }

  Future<void> register(String username,String password,String email) async {
    try {
      await _apiService.post("/user/",{
        "username":username,
        "password":password,
        "email":email
      });
    } catch(e) {
      print("Registration error: $e");
    }
  }

}