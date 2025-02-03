// user_service.dart
import 'dart:developer';
import 'package:question_nswer/core/constants/api_constants.dart';
import 'package:question_nswer/core/services/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getUserProfile() async {
    log("inside getuserprofile....");
    try {
      final response = await _apiService.get(ApiConstants.userProfileEndpoint);

      log("after userprofile has been received $response");

      if (response.statusCode == 200) {
        log("get request successful....");
        final userData = response.data;

        log("User data in getuserprofile ---$userData");
        return {
          'username': userData['username'],
          'email': userData['email'],
          'profile_picture': userData['profile_picture'], // Assuming the API returns an image URL
        };
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }
}