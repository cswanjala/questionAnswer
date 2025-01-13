import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/constants/api_constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<bool> register(String username, String email, String password, String confirmPassword) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(msg: "All fields must be filled");
      return false;
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: "Passwords do not match");
      return false;
    }

    try {
      final response = await _apiService.post(
        ApiConstants.registerEndpoint,
        {'username': username, 'email': email, 'password': password},
        requiresAuth: false,
      );

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Registration Successful!");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Registration failed: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.loginEndpoint,
        {'username': username, 'password': password},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _apiService.saveToken(data['access'], data['id'].toString());
        return true;
      } else {
        Fluttertoast.showToast(msg: "Login failed: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      return false;
    }
  }
}
