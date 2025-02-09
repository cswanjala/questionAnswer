// user_provider.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:question_nswer/core/services/users/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  Map<String, dynamic> get userData => _userData;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData() async {
    log("tryna fetch userdata...");
    _isLoading = true;
    notifyListeners();

    try {
      _userData = await _userService.getUserProfile();
      log("here is userdata "+_userData.toString());
    } catch (e) {
      // Handle error, e.g., show a toast or log the error
      print('Error fetching user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}