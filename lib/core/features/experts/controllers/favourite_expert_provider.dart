import 'package:flutter/material.dart';
import 'package:question_nswer/core/services/experts/favourite_expert_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FavoriteExpertsProvider with ChangeNotifier {
  final FavoriteExpertsService _favoriteExpertsService = FavoriteExpertsService();
  List<dynamic> _favoriteExperts = [];
  bool _isLoading = false;

  List<dynamic> get favoriteExperts => _favoriteExperts;
  bool get isLoading => _isLoading;

  Future<void> fetchFavoriteExperts(String userId) async {
    _isLoading = true;
    notifyListeners();

    _favoriteExperts = await _favoriteExpertsService.fetchFavoriteExperts(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshFavoriteExperts() async {
    _isLoading = true;
    notifyListeners();

    final secureStorage = FlutterSecureStorage();
    final userId = await secureStorage.read(key: 'user_id');
    if (userId != null) {
      _favoriteExperts = await _favoriteExpertsService.fetchFavoriteExperts(userId);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addFavoriteExpert(String userId, int expertId) async {
    _isLoading = true;
    notifyListeners();

    final success = await _favoriteExpertsService.addFavoriteExpert(userId, expertId);
    if (success) {
      await fetchFavoriteExperts(userId); // Refresh the favorite experts list
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> removeFavoriteExpert(String userId, int expertId) async {
    _isLoading = true;
    notifyListeners();

    final success = await _favoriteExpertsService.removeFavoriteExpert(userId, expertId);
    if (success) {
      await fetchFavoriteExperts(userId); // Refresh the favorite experts list
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }
}