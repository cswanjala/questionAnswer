import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  get errorMessage => null;

  Future<bool> register(String username, String email, String password, String confirmPassword) async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.register(username, email, password, confirmPassword);

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
