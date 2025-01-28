import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:question_nswer/core/features/users/controllers/users_provider.dart';
import 'package:question_nswer/core/services/api_service.dart';

class MessageProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _userMessages = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get userMessages => _userMessages;
  bool get isLoading => _isLoading;

  Future<void> fetchUserMessages(UserProvider userProvider) async {
    _isLoading = true;
    notifyListeners();
    log("[MessageProvider] Fetching user messages...");

    try {
      // Step 1: Ensure current user data is available dummy comment
      if (userProvider.currentUser == null) {
        log("[MessageProvider] No current user found. Cannot fetch messages.");
        _isLoading = false;
        notifyListeners();
        return;
      }

      final currentUserId = userProvider.currentUser!['id'];
      log("[MessageProvider] Current user ID: $currentUserId");

      // Step 2: Fetch messages from the API
      log("[MessageProvider] Fetching messages from API...");
      final response = await _apiService.get('/messages');
      log("[MessageProvider] API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> messages = response.data;
        log("[MessageProvider] Messages received: ${messages.length} messages found.");

        // Step 3: Filter messages where the sender ID matches the current user ID
        _userMessages = messages
            .where((message) => message['sender'] == currentUserId)
            .cast<Map<String, dynamic>>()
            .toList();

        log("[MessageProvider] Filtered messages: ${_userMessages.length} messages found for user ID $currentUserId");
      } else {
        log("[MessageProvider] Failed to fetch messages. Status Code: ${response.statusCode}");
        log("[MessageProvider] Response Data: ${response.data}");
        _userMessages = [];
      }
    } catch (e, stackTrace) {
      log("[MessageProvider] Error fetching user messages: $e",
          stackTrace: stackTrace);
      _userMessages = [];
    }

    _isLoading = false;
    log("[MessageProvider] Finished fetching messages. isLoading: $_isLoading");
    notifyListeners();
  }
}
