import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/services/auth_service.dart';
import 'dart:io';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  get errorMessage => null;

  Future<bool> register(String username, String email, String password, String confirmPassword, File? profileImage, bool isExpert, String title, List<String> categories) async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.register(username, email, password, confirmPassword, profileImage, isExpert, title, categories);

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.login(username, password);

    _isLoading = false;
    notifyListeners();
    return success;
  }
}
