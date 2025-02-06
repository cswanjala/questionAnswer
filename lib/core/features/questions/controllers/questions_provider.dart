import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/services/api_service.dart';

import 'dart:io';
import 'package:dio/dio.dart';

class QuestionsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _questions = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMore = true;

  List<dynamic> get questions => _questions;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;


  Future<void> fetchQuestions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/questions?page=1');
      if (response.statusCode == 200) {
        _questions = response.data;
        _page = 1;
        _hasMore = response.data.isNotEmpty;
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

  Future<void> fetchMoreQuestions() async {
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/questions?page=${_page + 1}');
      if (response.statusCode == 200) {
        if (response.data.isNotEmpty) {
          _questions.addAll(response.data);
          _page++;
          _hasMore = true;
        } else {
          _hasMore = false;
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch more questions: ${response.statusMessage}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching more questions: ${e.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshQuestions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/questions?page=1');
      if (response.statusCode == 200) {
        _questions = response.data;
        _page = 1;
        _hasMore = response.data.isNotEmpty;
      } else {
        Fluttertoast.showToast(msg: "Failed to refresh questions: ${response.statusMessage}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error refreshing questions: ${e.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addQuestion(String content, {File? image}) async {
    log("inside add question method");
    _isLoading = true;
    notifyListeners();

    try {
      log(":before form data is reached....");
      FormData formData = FormData.fromMap({
        'content': content,
        if (image != null)
          'image': await MultipartFile.fromFile(image.path,
              filename: image.path.split('/').last),
      });

      log(formData.fields.toString());

      final response = await _apiService.post('/questions/', formData);

      log("Response is $response");

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Question added successfully!");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to add question: ${response.data}");
        return false;
      }
    } catch (e) {
      
      return true;
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

  Future<void> submitQuestion(FormData formData) async {
    try {
      final response = await _apiService.post('/questions/', formData);
      if (response.statusCode == 201) {
        // Handle successful response
      } else {
        // Handle error response
      }
    } catch (e) {
      // Handle exception
    }
  }
}



