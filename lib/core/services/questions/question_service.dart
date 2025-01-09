import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/constants/api_constants.dart';
import 'package:question_nswer/core/services/api_service.dart';

class QuestionsService {
  final ApiService _apiService = ApiService();

  // Fetch all upcoming questions
  Future<List<dynamic>> fetchQuestions() async {
    try {
      final response = await _apiService.get(ApiConstants.questionsEndpoint);

      if (response.statusCode == 200) {
        // Fluttertoast.showToast(msg: "Questions fetched successfully");
        return response.data;
      } else {
        // Fluttertoast.showToast(msg: "Failed to fetch questions: ${response.data}");
        return [];
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log("${e}is the error");
      return [];
    }
  }

  // Add a new question
  Future<bool> addQuestion(String content, int categoryId, bool isExpert) async {
    if (content.isEmpty) {
      // Fluttertoast.showToast(msg: "Title and description must be filled");
      return false;
    }

    try {
      final response = await _apiService.post(
        ApiConstants.questionsEndpoint,
        {'content': content, 'category': categoryId, 'is_expert': isExpert},
      );

      if (response.statusCode == 201) {
        // Fluttertoast.showToast(msg: "Question added successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to add question: ${response.data}");
        return false;
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }

  // Update an existing question
  Future<bool> updateQuestion(int questionId, String title, String description, bool isExpert) async {
    if (title.isEmpty || description.isEmpty) {
      // Fluttertoast.showToast(msg: "Title and description must be filled");
      return false;
    }

    try {
      final response = await _apiService.put(
        "${ApiConstants.questionsEndpoint}/$questionId",
        {'title': title, 'description': description, 'is_expert': isExpert},
      );

      if (response.statusCode == 200) {
        // Fluttertoast.showToast(msg: "Question updated successfully");
        return true;
      } else {
        // Fluttertoast.showToast(msg: "Failed to update question: ${response.data}");
        return false;
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }

  // Delete a question
  Future<bool> deleteQuestion(int questionId) async {
    try {
      final response = await _apiService.delete(
        "${ApiConstants.questionsEndpoint}/$questionId",
      );

      if (response.statusCode == 204) {
        // Fluttertoast.showToast(msg: "Question deleted successfully");
        return true;
      } else {
        // Fluttertoast.showToast(msg: "Failed to delete question: ${response.data}");
        return false;
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }
}
