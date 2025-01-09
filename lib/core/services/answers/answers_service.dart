import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/constants/api_constants.dart';
import 'package:question_nswer/core/services/api_service.dart';

class AnswerService {
  final ApiService _apiService = ApiService();

  // Fetch all answers for a specific question
  Future<List<dynamic>> fetchAnswers(int questionId) async {
    try {
      final response = await _apiService.get('${ApiConstants.answersEndpoint}/$questionId');

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Answers fetched successfully!");
        return response.data;
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch answers: ${response.data}");
        return [];
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching answers: ${e.toString()}");
      log(e.toString());
      return [];
    }
  }

  // Add a new answer to a specific question
  Future<bool> addAnswer(int questionId, String content) async {
    if (content.isEmpty) {
      Fluttertoast.showToast(msg: "Answer content cannot be empty");
      return false;
    }

    try {
      final response = await _apiService.post(
        ApiConstants.answersEndpoint,
        {'question_id': questionId, 'content': content},
      );

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Answer added successfully!");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to add answer: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error adding answer: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }

  // Update an existing answer
  Future<bool> updateAnswer(int answerId, String content) async {
    if (content.isEmpty) {
      Fluttertoast.showToast(msg: "Answer content cannot be empty");
      return false;
    }

    try {
      final response = await _apiService.put(
        '${ApiConstants.answersEndpoint}/$answerId',
        {'content': content},
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Answer updated successfully!");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to update answer: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error updating answer: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }

  // Delete an answer
  Future<bool> deleteAnswer(int answerId) async {
    try {
      final response = await _apiService.delete('${ApiConstants.answersEndpoint}/$answerId');

      if (response.statusCode == 204) {
        Fluttertoast.showToast(msg: "Answer deleted successfully!");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to delete answer: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting answer: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }
}
