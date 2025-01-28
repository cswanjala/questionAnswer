import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/features/users/controllers/user_messages_provider.dart';
import 'package:question_nswer/core/features/users/controllers/users_provider.dart';
import 'chat_screen.dart';

class MessageScreen extends StatelessWidget {
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
        title: Text("Messages",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.grey[200]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text("Active Messages",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  SizedBox(width: 8),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.red,
                    child: Text(filteredMessages.length.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            Expanded(
              child: messageProvider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredMessages.isEmpty
                      ? Center(child: Text("No messages found."))
                      : ListView.builder(
                          itemCount: filteredMessages.length,
                          itemBuilder: (context, index) {
                            final message = filteredMessages[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      senderUsername: user?["username"],
                                      recipientUsername:
                                          message['recipient_username'],
                                      expertName: message['recipient_username'],
                                      expertImage: message[
                                              'recipient_profile_picture'] ??
                                          'assets/default_profile.png',
                                      expertCategory: 'Category Placeholder',
                                      authToken:
                                          Future.value(userProvider.authToken!),
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: Offset(0, 4)),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(12),
                                    leading: CircleAvatar(
                                      radius: 28,
                                      backgroundImage: message[
                                                  'recipient_profile_picture'] !=
                                              null
                                          ? NetworkImage(message[
                                              'recipient_profile_picture'])
                                          : AssetImage(
                                                  'assets/default_profile.png')
                                              as ImageProvider,
                                    ),
                                    title: Text(message['recipient_username'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message['message'],
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          message['timestamp'],
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
