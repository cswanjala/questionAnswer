import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class ChatScreen extends StatefulWidget {
  final String senderUsername;
  final String recipientUsername;
  final String expertName;
  final String? expertImage;
  final String expertCategory;
  final Future<String?> authToken;

  const ChatScreen({
    super.key,
    required this.senderUsername,
    required this.recipientUsername,
    required this.expertName,
    this.expertImage,
    this.expertCategory = 'category',
    required this.authToken,
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

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    final token = await widget.authToken;
    if (token == null) {
      log('Error: Unable to fetch auth token.');
      return;
    }

    final roomName = _generateRoomName(widget.senderUsername, widget.recipientUsername);
    await _loadPreviousMessages(roomName, token);
    _initializeWebSocket(roomName, token);
  }

  String _generateRoomName(String user1, String user2) {
    final participants = [user1, user2]..sort();
    return participants.join('_');
  }

  Future<void> _loadPreviousMessages(String roomName, String token) async {
    final url = Uri.parse('http://192.168.1.127:8000/api/get_chat_messages/$roomName/');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final messages = json.decode(response.body) as List;
        setState(() {
          _messages = messages.map((msg) => {
            'message': msg['message'],
            'sender_username': msg['sender'],
            'recipient_username': msg['receiver'],
          }).toList();
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        log('Failed to load previous messages: ${response.body}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      log('Error fetching previous messages: $e');
      setState(() => _isLoading = false);
    }
  }

  void _initializeWebSocket(String roomName, String token) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.127:8000/ws/chat/$roomName/?token=$token'),
    );

    _channel.stream.listen(
      (message) {
        final decodedMessage = json.decode(message);
        setState(() {
          _messages.add({
            'message': decodedMessage['message'],
            'sender_username': decodedMessage['sender'],
            'recipient_username': decodedMessage['receiver'],
          });
        });
        _scrollToBottom();
      },
      onError: (error) => log('WebSocket Error: $error'),
      onDone: () => log('WebSocket connection closed.'),
    );
  }

  void _sendMessage(String content) {
    if (content.isEmpty) return;

    final messageData = {
      'message': content,
      'sender': widget.senderUsername,
      'receiver': widget.recipientUsername,
    };
    _channel.sink.add(json.encode(messageData));
    _messageController.clear();
  }

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
              ),
            if (widget.expertImage != null) SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.expertName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  widget.expertCategory,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(child: Text('No messages yet.'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isUserMessage = message['sender_username'] == widget.senderUsername;

                          return Align(
                            alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isUserMessage ? Colors.blue : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                message['message'],
                                style: TextStyle(
                                  color: isUserMessage ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                ),
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
                  onPressed: () => _sendMessage(_messageController.text.trim()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}