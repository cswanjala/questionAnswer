import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/features/users/controllers/user_messages_provider.dart';
import 'package:question_nswer/core/features/users/controllers/users_provider.dart';
import 'chat_screen.dart';


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
    _startPolling();
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

  void _startPolling() {
    Future.delayed(Duration(seconds: 1), () async {
      final token = await secureStorage.read(key: 'auth_token');
      final username = await secureStorage.read(key: 'username');
      if (token != null && username != null) {
        await _fetchMessages(token, username);
      }
      _startPolling();
    });
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
      final sender = message['recipient_username'];
      final receiver = message['sender_username'];

      if (receiver == username) {
        lastMessages[sender] = message;
      }
      if (sender == username) {
        lastMessages[receiver] = message;
      }
    }

    return lastMessages;
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
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

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Stack(
        title: Text('Messages'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _lastMessages.length,
        itemBuilder: (context, index) {
          final key = _lastMessages.keys.elementAt(index);
          final message = _lastMessages[key];

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    child: Text(key[0].toUpperCase()),
                  ),
                  if (message['is_new'] == true)
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                key,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message['message']),
                  SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message['timestamp']),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              onTap: () {
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
                    child: Text(key[0].toUpperCase()),
                  ),
                  if (message['is_new'] == true)
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                key,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message['message']),
                  SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message['timestamp']),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              onTap: () {
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
            ),
          );
        },
          );
        },
      ),
    );
  }
}
