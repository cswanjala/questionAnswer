import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/services/api_service.dart';

import 'dart:io';
import 'package:dio/dio.dart';

class QuestionsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> get questions => _questions;

  Future<void> fetchQuestions() async {
    log("----fetch questions hit-----");
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/questions');
      log(response.toString());
      if (response.statusCode == 200) {
        _questions = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch questions: ${response.statusMessage}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching questions: ${e.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addQuestion(String content, int categoryId, {File? image}) async {
    _isLoading = true;
    notifyListeners();

    try {
      FormData formData = FormData.fromMap({
        'content': content,
        'category': categoryId,
        if (image != null)
          'image': await MultipartFile.fromFile(image.path,
              filename: image.path.split('/').last),
      });

      final response = await _apiService.post('/questions/', formData);

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Question added successfully!");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to add question: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error adding question: ${e.toString()}");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateQuestion(int questionId, String content, int categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.put('/questions/$questionId', {
        'content': content,
        'category': categoryId,
      });

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Question updated successfully!");
        await fetchQuestions(); // Refresh the questions list
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to update question: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error updating question: ${e.toString()}");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteQuestion(int questionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.delete('/questions/$questionId');

      if (response.statusCode == 204) {
        Fluttertoast.showToast(msg: "Question deleted successfully!");
        await fetchQuestions(); // Refresh the questions list
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to delete question: ${response.statusMessage}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting question: ${e.toString()}");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
