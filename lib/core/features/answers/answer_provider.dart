import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/services/answers/answers_service.dart';

class AnswerProvider with ChangeNotifier {
  final AnswerService _answerService = AnswerService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _answers = [];
  List<Map<String, dynamic>> get answers => _answers;

  // Fetch answers for a specific question
  Future<void> fetchAnswers(int questionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedAnswers = await _answerService.fetchAnswers(questionId);
      _answers = List<Map<String, dynamic>>.from(fetchedAnswers);
      notifyListeners();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching answers: ${e.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new answer to a question
  Future<bool> addAnswer(int questionId, String content) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _answerService.addAnswer(questionId, content);
      if (success) {
        await fetchAnswers(questionId); // Refresh the answers list
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error adding answer: ${e.toString()}");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing answer
  Future<bool> updateAnswer(int answerId, int questionId, String content) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _answerService.updateAnswer(answerId, content);
      if (success) {
        await fetchAnswers(questionId); // Refresh the answers list
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error updating answer: ${e.toString()}");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete an answer
  Future<bool> deleteAnswer(int answerId, int questionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _answerService.deleteAnswer(answerId);
      if (success) {
        await fetchAnswers(questionId); // Refresh the answers list
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting answer: ${e.toString()}");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
