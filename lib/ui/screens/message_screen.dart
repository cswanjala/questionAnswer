import 'package:flutter/material.dart';
import 'chat_screen.dart'; // Import the ChatScreen

class MessagesScreen extends StatelessWidget {
  // Dummy conversations data
  final List<Conversation> conversations = List.generate(
    15,
    (index) => Conversation(
      name: "Expert ${index + 1}",
      lastMessage: "This is the last message from Expert ${index + 1}.",
      timestamp: "${index + 1}:00 PM",
      profilePicture:
          "assets/profile_placeholder.png", // Replace with actual image path
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];

          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(conversation.profilePicture),
                radius: 25,
              ),
              title: Text(
                conversation.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                conversation.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                conversation.timestamp,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                // Navigate to the ChatScreen with the selected expert's name
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatScreen(expertName: conversation.name),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Dummy conversation data model
class Conversation {
  final String name;
  final String lastMessage;
  final String timestamp;
  final String profilePicture;

  Conversation({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.profilePicture,
  });
}
