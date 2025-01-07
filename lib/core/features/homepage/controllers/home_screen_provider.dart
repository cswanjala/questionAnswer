import 'package:flutter/material.dart';
import 'package:question_nswer/core/services/api_service.dart';

class HomeScreenProvider with ChangeNotifier {
  final ApiService _apiService;

  HomeScreenProvider(this._apiService);

  // State variables
  List<dynamic> _questions = [];
  List<dynamic> _experts = [];
  bool _isLoadingQuestions = false;
  bool _isLoadingExperts = false;
  String? _questionsError;
  String? _expertsError;

  // Getters
  List<dynamic> get questions => _questions;
  List<dynamic> get experts => _experts;
  bool get isLoadingQuestions => _isLoadingQuestions;
  bool get isLoadingExperts => _isLoadingExperts;
  String? get questionsError => _questionsError;
  String? get expertsError => _expertsError;

  // Fetch active questions
  Future<void> fetchQuestions() async {
    _isLoadingQuestions = true;
    _questionsError = null;
    notifyListeners();

    try {
      final data = await _apiService.get('/questions');
      _questions = data.data;
    } catch (error) {
      _questionsError = "Failed to fetch questions: $error";
    } finally {
      _isLoadingQuestions = false;
      notifyListeners();
    }
  }

  // Fetch favorite experts
  Future<void> fetchExperts() async {
    _isLoadingExperts = true;
    _expertsError = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchExperts();
      _experts = data;
    } catch (error) {
      _expertsError = "Failed to fetch experts: $error";
    } finally {
      _isLoadingExperts = false;
      notifyListeners();
    }
  }
}
