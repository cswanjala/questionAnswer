import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/features/users/controllers/users_provider.dart';
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
    final userProvider = Provider.of<UserProvider>(context);

    // Fetch user data only if it's not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!userProvider.isLoading && userProvider.currentUser == null) {
        await userProvider.fetchCurrentUser();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userProvider.isLoading)
              Center(child: CircularProgressIndicator()),
            SizedBox(height: 20),
            _buildProfileSection(userProvider),
            Divider(thickness: 1),
            _buildMembershipInfo(userProvider),
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

  Widget _buildProfileSection(UserProvider userProvider) {
    final user = userProvider.currentUser;

    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blue[100],
          backgroundImage: user?["profile_picture"] != null
              ? NetworkImage(user!["profile_picture"])
              : null,
          child: user?["profile_picture"] == null
              ? Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.blue,
                )
              : null,
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?["username"] ?? 'Unknown User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              user?["email"] ?? 'No email available',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembershipInfo(UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Membership Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Status: No subscriptions',
          style: TextStyle(fontSize: 14, color: Colors.black87),
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
