import 'package:flutter/material.dart';

class UpgradeCryptoMembershipPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upgrade to Crypto Membership"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    "Upgrade Your Membership!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Unlock exclusive perks: priority support, expert guidance, crypto rewards, and more!",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Pricing Options
            Text(
              "Choose Your Plan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.currency_bitcoin, color: Colors.orangeAccent, size: 30),
                title: Text("Monthly Membership"),
                subtitle: Text("0.001 BTC/month"),
                trailing: ElevatedButton(
                  onPressed: () {
                    _showPaymentDialog(context, "Monthly Membership", "0.001 BTC");
                  },
                  child: Text("Upgrade"),
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.currency_exchange, color: Colors.blueAccent, size: 30),
                title: Text("Annual Membership"),
                subtitle: Text("0.01 BTC/year"),
                trailing: ElevatedButton(
                  onPressed: () {
                    _showPaymentDialog(context, "Annual Membership", "0.01 BTC");
                  },
                  child: Text("Upgrade"),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Additional Info Section
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Why Upgrade?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "\u2022 Earn crypto rewards directly to your wallet.\n\u2022 Access premium content and exclusive events.\n\u2022 Get early access to new features.",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Call to Action
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showPaymentDialog(context, "Custom Plan", "TBD");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.currency_bitcoin, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Pay with Crypto",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, String planName, String price) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Crypto Payment",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Plan: $planName",
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                ),
                Text(
                  "Price: $price",
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text(
                    "Proceed to Pay",
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
