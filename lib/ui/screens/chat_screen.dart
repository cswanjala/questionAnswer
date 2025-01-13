import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String expertName;
  final String expertImage;
  final String expertCategory;
  final int recipientId;
  final Future<String?> authToken;

  const ChatScreen({
    super.key,
    required this.expertName,
    required this.expertImage,
    required this.expertCategory,
    required this.recipientId,
    required this.authToken,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.220.229:8000/api/chat-messages/${widget.recipientId}'),
        headers: {'Authorization': 'Bearer ${widget.authToken}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.220.229:8000/api/chat-messages/'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'recipient': widget.recipientId,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _messages.add(json.decode(response.body));
          _messageController.clear();
        });
      } else {
        print('Failed to send message: ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(CupertinoIcons.chevron_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.expertImage),
              radius: 20,
            ),
            SizedBox(width: 10),
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
            child: _messages.isEmpty
                ? Center(child: Text('No messages yet.'))
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUserMessage = message['sender'] == 'current_user'; // Replace with actual logic
                      return Align(
                        alignment: isUserMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isUserMessage ? Colors.blue : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            message['content'],
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
                IconButton(
                  icon: Icon(CupertinoIcons.paperclip, color: Colors.blue),
                  onPressed: () {
                    // Handle file attachments
                  },
                ),
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
                  icon: Icon(CupertinoIcons.paperplane_fill, color: Colors.blue),
                  onPressed: () {
                    final content = _messageController.text.trim();
                    if (content.isNotEmpty) {
                      sendMessage(content);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void navigateToChatScreen(BuildContext context, String expertName, String expertImage, String expertCategory, int recipientId, Future<String?> authToken) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        expertName: expertName,
        expertImage: expertImage,
        expertCategory: expertCategory,
        recipientId: recipientId,
        authToken: authToken,
      ),
    ),
  );
}