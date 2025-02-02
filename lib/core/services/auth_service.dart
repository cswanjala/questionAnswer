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
        log("Register Response Status: ${response.statusCode}");
        log("Register Response Data: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log("Error during registration: ${e.toString()}");
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    log("Inside login method");

    try {
      final response = await _apiService.post(
        ApiConstants.loginEndpoint,
        {'username': username, 'password': password},
        requiresAuth: false,
      );

      // Log the complete response to understand its structure
      log("Login Response Status: ${response.statusCode}");
      log("Login Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        // Log the 'data' variable to inspect its structure
        log("Login Data: ${data}");

        if (data is Map<String, dynamic>) {
          log("Access Token: ${data['access']}");
          log("User ID: ${data['id']}");
          log("Username: ${data['username']}");
        } else {
          log("Unexpected data format: ${data.runtimeType}");
        }

        // Save token, user_id, and username securely
        await _apiService.saveToken(data['access'], data['id'].toString(), data['username'],data['is_expert']);
        
        return true;
      } else {
        Fluttertoast.showToast(msg: "Login failed: ${response.data}");
        log("Login Failed Response: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log("Error during login: ${e.toString()}");
      return false;
    }
  }
}
