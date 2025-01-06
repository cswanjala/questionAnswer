import 'package:flutter/material.dart';
import 'package:question_nswer/ui/screens/crypto_memebership_screen.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.blueAccent,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      "https://via.placeholder.com/150"), // Replace with actual image URL
                ),
                SizedBox(height: 10),
                Text(
                  "John Doe",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "john.doe@example.com",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
          // Account Options
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                // Crypto Membership
                Card(
                  child: ListTile(
                    leading: Icon(Icons.currency_bitcoin, color: Colors.orangeAccent),
                    title: Text("Crypto Membership"),
                    subtitle: Text("Join our crypto membership program"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CryptoMembershipPage()),
                      );
                    },
                  ),
                ),
                // Other Account Options
                Card(
                  child: ListTile(
                    leading: Icon(Icons.settings, color: Colors.blueAccent),
                    title: Text("Settings"),
                    subtitle: Text("Manage your preferences"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to Settings Page
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.redAccent),
                    title: Text("Log Out"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Handle Log Out
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
