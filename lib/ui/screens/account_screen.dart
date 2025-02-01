import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/services/api_service.dart';
import 'package:question_nswer/ui/screens/add_credit_card_screen.dart';
import 'package:question_nswer/ui/screens/payments_screen.dart';
import 'package:question_nswer/ui/screens/splash_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  Map<String, String?> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final userData = await apiService.getUserData();

    setState(() {
      _userData = userData;
      _isLoading = false;
    });
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProfileSection(),
            const Divider(thickness: 1),
            _buildMembershipInfo(),
            const Divider(thickness: 1),
            _buildAccountOptions(context),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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

  Widget _buildProfileSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blue[100],
          child: const Icon(
            Icons.person,
            size: 50,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLoading ? 'Loading...' : _userData['username'] ?? 'Guest',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _isLoading ? 'Loading...' : _userData['email'] ?? 'No email',
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
          'Status: ${_isLoading ? 'Loading...' : 'Premium Member'}',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          'Expiry: ${_isLoading ? 'Loading...' : '12/31/2025'}',
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
          onTap: () {
            // Navigate to change password screen (to be implemented)
          },
        ),
        ListTile(
          leading: const Icon(Icons.credit_card, color: Colors.blue),
          title: const Text('Add Credit Card', style: TextStyle(fontSize: 16)),
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