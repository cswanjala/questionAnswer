import 'package:flutter/material.dart';
import 'package:question_nswer/ui/screens/package_details.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileSection(),
            SizedBox(height: 16.0),
            _buildBadgesSection(),
            SizedBox(height: 16.0),
            _buildActivitySummarySection(),
            SizedBox(height: 16.0),
            _buildMembershipSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/profile_placeholder.png'),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    'Location: City, Country',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  Text(
                    'Last seen: Today at 3:00 PM',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection() {
    final badges = List.generate(
      6,
      (index) => CircleAvatar(
        radius: 30,
        backgroundColor: Colors.blueAccent.withOpacity(0.2),
        child: Icon(Icons.verified, color: Colors.blue, size: 30),
      ),
    );

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Badges',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8.0),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: badges,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySummarySection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8.0),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.blue),
              title: Text('Messages Sent'),
              trailing: Text('123'),
            ),
            ListTile(
              leading: Icon(Icons.task, color: Colors.green),
              title: Text('Tasks Completed'),
              trailing: Text('45'),
            ),
            ListTile(
              leading: Icon(Icons.star, color: Colors.orange),
              title: Text('Average Rating'),
              trailing: Text('4.5'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipSection(BuildContext context) {
    final membershipPackages = [
      {'title': 'Silver Membership', 'price': 0.01},
      {'title': 'Gold Membership', 'price': 0.03},
      {'title': 'Platinum Membership', 'price': 0.05},
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Membership Packages',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8.0),
            ...membershipPackages.map((package) {
              return ListTile(
                leading: Icon(Icons.card_membership, color: Colors.amber),
                title: Text(package['title'] as String),
                trailing: Text(
                  '${package['price']} BTC',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // Navigate to the package details screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PackageDetailsScreen(
                        title: package['title'] as String,
                        price: package['price'] as double,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
