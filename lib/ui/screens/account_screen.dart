// account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/features/users/user_provider.dart';
import 'package:question_nswer/ui/screens/payments_screen.dart';
import 'package:question_nswer/ui/screens/splash_screen.dart';
import 'package:question_nswer/ui/screens/change_password_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String membershipStatus = 'Basic';

  @override
  void initState() {
    super.initState();
    // Fetch user data and membership status when the screen is initialized
    Provider.of<UserProvider>(context, listen: false).fetchUserData();
    _fetchMembershipStatus();
  }

  Future<void> _fetchMembershipStatus() async {
    final storage = FlutterSecureStorage();
    String? userId = await storage.read(key: 'user_id');

    if (userId == null) {
      print("User ID not found in secure storage");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://50.6.205.45:8000/api/membership-plans/?user=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            membershipStatus = 'Premium';
          });
        }
      } else {
        print("Failed to fetch membership status: ${response.body}");
      }
    } catch (e) {
      print("Error fetching membership status: $e");
    }
  }

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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProfileSection(userProvider),
            const Divider(thickness: 1),
            _buildMembershipInfo(),
            const Divider(thickness: 1),
            _buildAccountOptions(context),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Use the same color as the Submit button
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
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
    String baseUrl = "http://50.6.205.45:8000"; // Replace with your actual API base URL
    String? profilePicturePath = userProvider.userData['profile_picture'];
    String fullProfilePictureUrl = profilePicturePath != null && !profilePicturePath.startsWith('http')
        ? '$baseUrl$profilePicturePath'
        : profilePicturePath ?? '';

    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blue[100],
          backgroundImage: profilePicturePath != null
              ? NetworkImage(fullProfilePictureUrl)
              : AssetImage('assets/images/default_avatar.png') as ImageProvider,
          onBackgroundImageError: (_, __) {
            // Fallback in case image fails to load
          },
          child: profilePicturePath == null
              ? ClipOval(
                  child: Image.asset(
                    'assets/images/default_avatar.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userProvider.isLoading ? 'Loading...' : userProvider.userData['username'] ?? 'Guest',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userProvider.isLoading ? 'Loading...' : userProvider.userData['email'] ?? 'No email',
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
        const Text(
          'Membership Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Status: $membershipStatus Member',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        if (membershipStatus == 'Premium')
          Text(
            'Expiry: 12/31/2025',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
      ],
    );
  }

  Widget _buildAccountOptions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.settings, color: Colors.blue),
          title: const Text('Settings', style: TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {
            // Navigate to settings screen (to be implemented)
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock, color: Colors.blue),
          title: const Text('Change Password', style: TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          // onTap: () {
          //   // Navigate to Change Password Screen
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
          //   );
          // },
        ),
        ListTile(
          leading: const Icon(Icons.credit_card, color: Colors.blue),
          title: const Text('Upgrade Membership', style: TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {
            // Navigate to Add Credit Card Screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.help, color: Colors.blue),
          title: const Text('Help & Support', style: TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {
            // Navigate to help & support screen (to be implemented)
          },
        ),
      ],
    );
  }
}