import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'chat_screen.dart'; // Import ChatScreen

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic> _lastMessages = {};
  bool _isLoading = true;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _initializeMessages();
  }

  Future<void> _initializeMessages() async {
    final token = await secureStorage.read(key: 'auth_token');
    final username = await secureStorage.read(key: 'username');
    _currentUsername = username;

    if (token != null && username != null) {
      await _fetchMessages(token, username);
    } else {
      log('Error: Unable to fetch auth token or username.');
    }
  }

  Future<void> _fetchMessages(String token, String username) async {
    final url = Uri.parse('http://192.168.1.127:8000/api/messages/');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = json.decode(response.body);
        setState(() {
          _messages = List<Map<String, dynamic>>.from(messages);
          _lastMessages = _getLastMessages(_messages, username);
          _isLoading = false;
        });
      } else {
        log('Failed to load messages: ${response.body}');
      }
    } catch (e) {
      log('Error fetching messages: $e');
    }
  }

  Map<String, dynamic> _getLastMessages(List<Map<String, dynamic>> messages, String username) {
    final Map<String, dynamic> lastMessages = {};

    for (var message in messages) {
      final sender = message['sender_username'];
      final receiver = message['recipient_username'];

      if (receiver == username) {
        lastMessages[sender] = message;
      }
    }

    return lastMessages;
  }

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Fetch user data only if it's not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!userProvider.isLoading && userProvider.currentUser == null) {
        await userProvider.fetchCurrentUser();
      }
    });

    if (userProvider.currentUser != null &&
        !messageProvider.isLoading &&
        messageProvider.userMessages.isEmpty) {
      messageProvider.fetchUserMessages(userProvider);
    }

    final user = userProvider.currentUser;

    // Filter messages to show only the latest per sender
    final Map<String, Map<String, dynamic>> latestMessages = {};
    for (var message in messageProvider.userMessages.reversed) {
      final sender = message['sender_username'];
      final recipient = message['recipient_username'];
      final key = '$sender-$recipient'; // Unique key for sender-recipient pair

      if (!latestMessages.containsKey(key)) {
        latestMessages[key] =
            message; // Store only the latest message per sender-recipient pair
      }
    }

    final List<Map<String, dynamic>> filteredMessages =
        latestMessages.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _lastMessages.length,
        itemBuilder: (context, index) {
          final key = _lastMessages.keys.elementAt(index);
          final message = _lastMessages[key];

          return ListTile(
            leading: CircleAvatar(
              child: Text(key[0].toUpperCase()),
            ),
            title: Text(key),
            subtitle: Text(message['message']),
            onTap: () {
              log(message.toString());
              log("The current username(senderUsername) is "+message['sender_username']);
              log("The receiver is "+message['recipient_username']);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    senderUsername: message['sender_username'],
                    recipientUsername: message['recipient_username'],
                    expertName: key,
                    expertImage: null, // Adjust as needed
                    expertCategory: 'category', // Adjust as needed
                    authToken: secureStorage.read(key: 'auth_token'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}