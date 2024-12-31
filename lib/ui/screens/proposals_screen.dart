import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProposalsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proposals'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          final expertName = 'Expert ${index + 1}';
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              leading: CircleAvatar(
                backgroundImage: AssetImage(
                    'assets/profile_placeholder.png'), // Replace with actual image path
              ),
              title: Text(
                expertName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Offering: \$${(index + 1) * 50}',
                      style: TextStyle(color: Colors.green, fontSize: 14)),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text('${4 + (index % 2) * 0.5}',
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Text('Location: City ${index + 1}',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(expertName: expertName),
                        ),
                      );
                    },
                    child: Text('Message'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to hire action
                      Fluttertoast.showToast(
                        msg: "You have successfully hired the Expert!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text('Hire'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
