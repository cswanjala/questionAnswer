import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:question_nswer/core/services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> fetchCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Step 1: Get auth token and username from storage
      final userData = await _apiService.getUserData();
      final username = userData['username'];
      final token = userData['auth_token'];

      if (token == null || username == null) {
        log("No auth token or username found.");
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Step 2: Fetch all users from /users endpoint
      final response = await _apiService.get('/users');
      if (response.statusCode == 200) {
        List<dynamic> users = response.data;

        // Step 3: Find the user with the matching username
        final user = users.firstWhere(
          (user) => user['username'] == username,
          orElse: () => null,
        );

        if (user != null) {
          _currentUser = user;
          log("User found: $_currentUser");
        } else {
          log("No matching user found.");
          _currentUser = null;
        }
      } else {
        log("Failed to fetch users: ${response.statusCode}");
        _currentUser = null;
      }
    } catch (e) {
      log("Error fetching user data: $e");
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}
