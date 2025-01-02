import 'package:flutter/material.dart';
import 'upgrade_crypto_membership.dart';

class CryptoMembershipPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crypto Membership"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enhance Your Q&A Experience!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Unlock exclusive benefits by joining our Crypto Membership program.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      "Join Now",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Features Section
            Text(
              "Membership Benefits",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            _buildFeatureTile(
              "Priority Question Review",
              "Your questions get prioritized for faster and detailed responses.",
              Icons.star_rate,
            ),
            _buildFeatureTile(
              "Earn Crypto Rewards",
              "Earn cryptocurrency for every question answered by our experts.",
              Icons.currency_bitcoin,
            ),
            _buildFeatureTile(
              "Exclusive Expert Access",
              "Connect with our top-rated experts directly for personalized help.",
              Icons.person_pin,
            ),
            _buildFeatureTile(
              "Crypto Payment Options",
              "Use your crypto wallet for seamless transactions.",
              Icons.wallet,
            ),
            SizedBox(height: 20),
            // Call-to-Action Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Ready to Experience the Future of Q&A?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpgradeCryptoMembershipPage()),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
  ),
  child: Text(
    "Upgrade to Crypto Membership",
    style: TextStyle(fontSize: 16, color: Colors.white),
  ),
),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(String title, String description, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.orangeAccent, size: 30),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}
