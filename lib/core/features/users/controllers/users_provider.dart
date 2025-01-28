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
    log("[UserProvider] Fetching current user...");

    try {
      // Step 1: Get auth token and username from storage
      log("[UserProvider] Retrieving user data from storage...");
      final userData = await _apiService.getUserData();
      log("[UserProvider] User data retrieved: $userData");

      final username = userData['username'];
      final token = userData['auth_token'];

      if (token == null || username == null) {
        log("[UserProvider] No auth token or username found.");
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Step 2: Fetch all users from /users endpoint
      log("[UserProvider] Fetching users from API...");
      final response = await _apiService.get('/users');
      log("[UserProvider] API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> users = response.data;
        log("[UserProvider] Users received: ${users.length} users found.");

        // Step 3: Find the user with the matching username
        final user = users.firstWhere(
          (user) => user['username'] == username,
          orElse: () {
            log("[UserProvider] No matching user found for username: $username");
            return null;
          },
        );

        if (user != null) {
          _currentUser = user;
          log("[UserProvider] User found: $_currentUser");
        } else {
          log("[UserProvider] No user matched.");
          _currentUser = null;
        }
      } else {
        log("[UserProvider] Failed to fetch users. Status Code: ${response.statusCode}");
        log("[UserProvider] Response Data: ${response.data}");
        _currentUser = null;
      }
    } catch (e, stackTrace) {
      log("[UserProvider] Error fetching user data: $e",
          stackTrace: stackTrace);
      _currentUser = null;
    }

    _isLoading = false;
    log("[UserProvider] Finished fetching user. isLoading: $_isLoading");
    notifyListeners();
  }
}
