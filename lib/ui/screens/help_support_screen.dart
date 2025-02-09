import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Help & Support',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'If you have any questions or need assistance, please contact us at:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Email: jadissa007@gmail.com',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text(
              'Phone: +1 234 567 890',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. How do I reset my password?',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              'Answer: You can reset your password by going to the settings page and selecting "Change Password".',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              '2. How do I upgrade my membership?',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              'Answer: You can upgrade your membership by going to the account page and selecting "Upgrade Membership".',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            // Add more FAQs as needed
          ],
        ),
      ),
    );
  }
}
