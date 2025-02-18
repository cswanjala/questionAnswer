import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:question_nswer/keys.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int amount = 2800;
  int displayAmount = 28;

  Map<String, dynamic>? intentPaymentData;

  showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        intentPaymentData = null;
        await saveMembershipPlan(); // Save membership plan after successful payment
      });
    } on Error catch (e) {
      print('Stripe error: ${e.toString()}');
    } on StripeException catch (e) {
      print('Stripe error: ${e.error.localizedMessage}');
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Error'),
          content: Text("Cancelled"),
        ),
      );
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
      print(errorMsg.toString());
    }
  }

  makeIntentForPayment(amountToBeCharged, currency) async {
    try {
      // Convert the amount to cents (if it's in dollars, for example, $20 becomes 2000 cents)
      int amountInCents = amountToBeCharged * 100;

      // Prepare the form data for the request, including the automatic payment method parameter
      Map<String, String> paymentInfo = {
        'amount': amountInCents
            .toString(), // Stripe expects the amount in the smallest currency unit
        'currency': currency,
        'automatic_payment_methods[enabled]':
            'true', // Add automatic payment methods enabled
      };

      var responseFromStripeApi = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: paymentInfo,
        headers: {
          "Authorization": "Bearer $SecretKey", // Use your Stripe Secret Key
          "Content-Type":
              "application/x-www-form-urlencoded", // Correct Content-Type
        },
      );

      print("Response from Stripe API: " + responseFromStripeApi.body);

      // Decode the response if it's successful
      return jsonDecode(responseFromStripeApi.body);
    } catch (errorMsg, s) {
      print(s?.toString());
      print(errorMsg?.toString());
    }
  }

  Future<void> paymentSheetInitialization(
      int amountToBeCharged, String currency) async {
    try {
      final intentPaymentData =
          await makeIntentForPayment(amountToBeCharged, currency);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret: intentPaymentData?['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'Cosiwa',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      await saveMembershipPlan(); // Save membership plan after successful payment
    } catch (errorMsg, s) {
      if (kDebugMode) {
        print(s);
      }
      print(s.toString());
    }
  }

  Future<void> saveMembershipPlan() async {
    final storage = FlutterSecureStorage();
    String? userId = await storage.read(key: 'user_id');

    if (userId == null) {
      print("User ID not found in secure storage");
      return;
    }

    final membershipPlanData = {
      'user': userId,
      'name': 'monthly',
      'price': 28,
      'duration_days': 30,
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.127:8000/api/membership-plans/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(membershipPlanData),
      );

      if (response.statusCode == 201) {
        print("Membership plan saved successfully.");
      } else {
        print("Failed to save membership plan: ${response.body}");
      }
    } catch (e) {
      print("Error saving membership plan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upgrade to Premium'),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why Upgrade to Premium?',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
            SizedBox(height: 20),
            Text(
              'As a premium member, you will enjoy the following benefits:',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 20),
            _buildBenefitTile('Unlimited questions without additional charges'),
            _buildBenefitTile('Priority access to top experts'),
            _buildBenefitTile('Exclusive content and resources'),
            _buildBenefitTile('Monthly webinars and Q&A sessions'),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  paymentSheetInitialization(
                    amount,
                    'USD',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue, // Use the same color as the Submit button
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Upgrade  for \$${displayAmount}.00',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitTile(String benefit) {
    return ListTile(
      leading: Icon(Icons.check_circle, color: Colors.green, size: 30),
      title: Text(
        benefit,
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}
