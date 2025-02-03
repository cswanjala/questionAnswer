import 'package:question_nswer/core/services/api_service.dart';
import 'dart:developer';

class RatingsService {
  static final ApiService _apiService = ApiService();

  static Future<void> submitRating(String recipientUsername, double rating, int questionId) async {
    log("question id is "+questionId.toString());
    final endpoint = '/ratings/';
    final data = {
      'recipient_username': recipientUsername,
      'stars': rating,
      'question': questionId,
    };

    try {
      final response = await _apiService.post(endpoint, data);
      if (response.statusCode == 201) {
        log('Rating submitted successfully');
      } else {
        log('Failed to submit rating: ${response.data}');
      }
    } catch (e) {
      log('Error submitting rating: $e');
    }
  }

  static Future<double> fetchAverageRating(int expertId) async {
    final endpoint = '/expert_average_rating/$expertId/';
    try {
      final response = await _apiService.get(endpoint);
      if (response.statusCode == 200) {
        final data = response.data;
        return data['average_rating']?.toDouble() ?? 0.0;
      } else {
        log('Failed to fetch average rating: ${response.data}');
        return 0.0;
      }
    } catch (e) {
      log('Error fetching average rating: $e');
      return 0.0;
    }
  }
}
