import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:question_nswer/ui/screens/add_credit_card_screen.dart';
import 'package:question_nswer/ui/screens/splash_screen.dart';

class AccountScreen extends StatelessWidget {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  AccountScreen({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await secureStorage.delete(key: 'auth_token'); // Delete auth token

    // Navigate to the splash screen and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildProfileSection(),
            Divider(thickness: 1),
            _buildMembershipInfo(),
            Divider(thickness: 1),
            _buildAccountOptions(context),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blue[100],
          child: Icon(
            Icons.person,
            size: 50,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'John Doe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'johndoe@example.com',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembershipInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Membership Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Status: Premium Member',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        SizedBox(height: 4),
        Text(
          'Expiry: 12/31/2025',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildAccountOptions(BuildContext context) {
  return Column(
    children: [
      ListTile(
        leading: Icon(Icons.settings, color: Colors.blue),
        title: Text('Settings', style: TextStyle(fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Navigate to settings screen (to be implemented)
        },
      ),
      ListTile(
        leading: Icon(Icons.lock, color: Colors.blue),
        title: Text('Change Password', style: TextStyle(fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Navigate to change password screen (to be implemented)
        },
      ),
      ListTile(
        leading: Icon(Icons.credit_card, color: Colors.blue),
        title: Text('Add Credit Card', style: TextStyle(fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Navigate to Add Credit Card Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCreditCardScreen()),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.help, color: Colors.blue),
        title: Text('Help & Support', style: TextStyle(fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Navigate to help & support screen (to be implemented)
        },
      ),
    ],
  );
}
}
