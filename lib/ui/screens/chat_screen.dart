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
    if (token != null) {
      final participants = [widget.senderUsername, widget.recipientUsername];
      participants.sort();
      final roomName = participants.join('_');
      await _loadPreviousMessages(roomName, token);
      _initializeWebSocket(roomName, token);
    } else {
      log('Error: Unable to fetch auth token.');
    }
  }

  Future<void> _loadPreviousMessages(String roomName, String token) async {
    final url = Uri.parse('http://192.168.1.127:8000/api/get_chat_messages/$roomName/');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final messages = json.decode(response.body) as List;
        setState(() {
          _messages = messages.map((msg) => {
            'message': msg['message'],
            'sender_username': msg['sender'],
            'recipient_username': msg['receiver'],
            'question_content': msg['content'],
          }).toList();
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _initializeWebSocket(String roomName, String token) {
    _channel = WebSocketChannel.connect(Uri.parse('ws://192.168.1.127:8000/ws/chat/$roomName/?token=$token'));

    _channel.stream.listen(
      (message) {
        final decodedMessage = json.decode(message);
        setState(() {
          _messages.add({
            'message': decodedMessage['message'],
            'sender_username': decodedMessage['sender'],
            'recipient_username': decodedMessage['receiver'],
            'question_content': decodedMessage['question']['content'],
          });
        });
        _scrollToBottom();
      },
      onError: (error) => log('WebSocket Error: $error'),
      onDone: () => log('WebSocket connection closed.'),
    );
  }

  void _sendMessage(String content) {
    if (content.isNotEmpty) {
      final messageData = {
        'message': content,
        'sender': widget.senderUsername,
        'receiver': widget.recipientUsername,
      };
      _channel.sink.add(json.encode(messageData));
      setState(() {
        _messages.add({
          'message': content,
          'sender_username': widget.senderUsername,
          'recipient_username': widget.recipientUsername,
        });
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
      appBar: AppBar(
        title: Text(widget.expertName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message['sender_username'] == widget.senderUsername;
                return Row(
                  mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isUserMessage ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        message['message'],
                        style: TextStyle(color: isUserMessage ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: "Type a message"),
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