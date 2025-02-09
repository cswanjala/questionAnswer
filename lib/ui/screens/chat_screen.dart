import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:question_nswer/services/ratings_service.dart';

class ChatScreen extends StatefulWidget {
  final String senderUsername;
  final String recipientUsername;
  final String expertName;
  final String? expertImage;
  final String expertCategory;
  final Future<String?> authToken;
  final int? questionId;
  final bool isExpert; // Add this field to determine if the user is an expert

  const ChatScreen({
    super.key,
    required this.senderUsername,
    required this.recipientUsername,
    required this.expertName,
    this.expertImage,
    this.expertCategory = 'category',
    required this.authToken,
    this.questionId,
    required this.isExpert, // Initialize this field
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel _channel;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _currentUsername;
  bool _isChatEnded = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  // Initialize chat: Fetch user, load messages, and connect WebSocket
  Future<void> _initializeChat() async {
    log("The image URL is ${widget.expertImage}");
    await _getCurrentUsername();
    final token = await widget.authToken;
    if (token == null) {
      log('Error: Unable to fetch auth token.');
      return;
    }

    final roomName =
        _generateRoomName(widget.senderUsername, widget.recipientUsername);
    await _loadPreviousMessages(roomName, token);
    _initializeWebSocket(roomName, token);
  }

  // Fetch current username from Secure Storage
  Future<void> _getCurrentUsername() async {
    final storage = FlutterSecureStorage();
    final username = await storage.read(key: 'username');
    setState(() {
      _currentUsername = username;
      _isLoading = false;
    });
  }

  // Generate a unique room name
  String _generateRoomName(String user1, String user2) {
    final participants = [user1, user2]..sort();
    final questionId =
        widget.questionId ?? 0; // Default to 0 if questionId is null
    return '${participants.join('_')}_$questionId';
  }

  // Load previous chat messages from the backend
  Future<void> _loadPreviousMessages(String roomName, String token) async {
    final url =
        Uri.parse('http://50.6.205.45:8000/api/get_chat_messages/$roomName/');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final messages = json.decode(response.body) as List;
        setState(() {
          _messages = messages
              .map((msg) => {
                    'message': msg['message'],
                    'sender_username': msg['sender'].trim(),
                    'recipient_username': msg['receiver'].trim(),
                  })
              .toList();
        });
        _scrollToBottom();
      } else {
        log('Failed to load previous messages: ${response.body}');
      }
    } catch (e) {
      log('Error fetching previous messages: $e');
    }
  }

  // Initialize WebSocket connection
  void _initializeWebSocket(String roomName, String token) {
    final questionId =
        widget.questionId ?? 0; // Default to 0 if questionId is null
    _channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://50.6.205.45:8000/ws/chat/$roomName/$questionId/?token=$token'),
    );

    _channel.stream.listen(
      (message) {
        log("Received message: $message");
        final decodedMessage = json.decode(message);
        setState(() {
          _messages.add({
            'message': decodedMessage['message'],
            'sender_username': decodedMessage['sender'].trim(),
            'recipient_username': decodedMessage['receiver'].trim(),
          });
        });
        _scrollToBottom();
      },
      onError: (error) => log('WebSocket Error: $error'),
      onDone: () => log('WebSocket connection closed.'),
    );
  }

  // Send a message via WebSocket
  void _sendMessage(String content) {
    if (content.isEmpty) return;

    final messageData = {
      'message': content,
      'sender': widget.senderUsername,
      'receiver': widget.recipientUsername,
      'question_id': widget.questionId, // Include questionId in messageData
    };
    _channel.sink.add(json.encode(messageData));
    _messageController.clear();
  }

  // Scroll to the latest message
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // End chat session and show rating dialog
  void _endChatSession() {
    setState(() {
      _isChatEnded = true;
    });
    _showRatingDialog();
  }

  // Show rating dialog
  void _showRatingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        double _rating = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rate the Expert',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Please rate your experience with ${widget.expertName}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Handle rating submission
                      await RatingsService.submitRating(
                          widget.recipientUsername,
                          _rating,
                          widget.questionId ?? 0);
                      Navigator.pop(context);
                      log('User rated: $_rating');
                    },
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            if (widget.expertImage != null)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.expertImage!),
                radius: 20,
              )
            else
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/default_avatar.png'),
                radius: 20,
              ),
            if (widget.expertImage != null || widget.expertName != null)
              SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.expertName,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Text(widget.expertCategory,
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          if (!widget
              .isExpert) // Only show the option to end chat if the user is not an expert
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'End Chat') {
                  _endChatSession();
                }
              },
              itemBuilder: (BuildContext context) {
                return {'End Chat'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _isChatEnded
                    ? Center(child: Text('Chat session has ended.'))
                    : _messages.isEmpty
                        ? Center(child: Text('No messages yet.'))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isUserMessage =
                                  message['sender_username'] ==
                                      _currentUsername;

                              return Align(
                                alignment: isUserMessage
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  margin: EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isUserMessage
                                        ? Colors.blue
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    message['message'],
                                    style: TextStyle(
                                        color: isUserMessage
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          if (!_isChatEnded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: () =>
                        _sendMessage(_messageController.text.trim()),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
