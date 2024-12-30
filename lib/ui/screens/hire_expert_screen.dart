import 'package:flutter/material.dart';

class HireExpertScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hire an Expert'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hire an Expert for Your Question',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              title: Text('Expert Name'),
              subtitle: Text('Expertise: Topic Area'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Handle hire logic
                },
                child: Text('Hire'),
              ),
            ),
            Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              title: Text('Expert Name 2'),
              subtitle: Text('Expertise: Topic Area 2'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Handle hire logic
                },
                child: Text('Hire'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
