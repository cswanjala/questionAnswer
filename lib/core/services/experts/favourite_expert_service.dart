import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/constants/api_constants.dart';
import 'package:question_nswer/core/services/api_service.dart';

class FavoriteExpertsService {
  final ApiService _apiService = ApiService();

  // Fetch favorite experts for a user
  Future<List<dynamic>> fetchFavoriteExperts(String userId) async {
    try {
      final response = await _apiService.get(ApiConstants.favoriteExpertsEndpoint);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Favorite experts fetched successfully");
        return response.data;
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch favorite experts: ${response.data}");
        return [];
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return [];
    }
  }

  // Add a favorite expert for a user
  Future<bool> addFavoriteExpert(String userId, int expertId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.favoriteExpertsEndpoint,
        {'user': userId, 'expert': expertId},
      );

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Favorite expert added successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to add favorite expert: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }

  // Remove a favorite expert for a user
  Future<bool> removeFavoriteExpert(String userId, int expertId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.favoriteExpertsEndpoint}/$userId/$expertId',
      );

      if (response.statusCode == 204) {
        Fluttertoast.showToast(msg: "Favorite expert removed successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to remove favorite expert: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }
}