import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:question_nswer/core/services/api_service.dart';
import 'package:question_nswer/keys.dart';
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _apiService = ApiService();
  int amount = 2800;
  String membershipPlanName = "expertmonthly"; // Add membership plan name

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

      // Prepare the form data for the request, including the membership plan name
      Map<String, String> paymentInfo = {
        'amount': amountInCents.toString(),  // Stripe expects the amount in the smallest currency unit
        'currency': currency,
        'automatic_payment_methods[enabled]': 'true',  // Add automatic payment methods enabled
        'metadata[membership_plan]': membershipPlanName, // Add membership plan name to metadata
      };

      var responseFromStripeApi = await _apiService.post(
        'https://api.stripe.com/v1/payment_intents',
        paymentInfo,
        requiresAuth: false,
      );

      print("Response from Stripe API: " + responseFromStripeApi.data);

      // Decode the response if it's successful
      return jsonDecode(responseFromStripeApi.data);
    } catch (errorMsg, s) {
      print(s?.toString());
      print(errorMsg?.toString());
    }
  }

  paymentSheetInitialization(amountToBeCharged, currency) async {
    try {
      intentPaymentData = await makeIntentForPayment(amountToBeCharged, currency);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret: intentPaymentData?['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'Cosiwa',
        ),
      ).then((value) => {
        print(value)
      });

      showPaymentSheet();
    } catch (errorMsg, s) {
      if (kDebugMode) {
        print(s);
      }
      print(s.toString());
    }
  }

  Future<void> saveMembershipPlan() async {
    try {
      final userData = await _apiService.getUserData();
      String? userId = userData['user_id'];

      final response = await _apiService.post(
        '/api/membership-plans/',
        jsonEncode({
          'user': userId, // Replace with actual user ID from secure storage
          'name': membershipPlanName,
          'price': amount / 100,
          'duration_days': 30, // Example duration
          'can_ask_unlimited': true,
          'can_chat_with_expert': true,
        }),
      );

      if (response.statusCode == 200) {
        print('Membership plan saved successfully');
      } else {
        print('Failed to save membership plan');
      }
    } catch (e) {
      print('Error saving membership plan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stripe Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            paymentSheetInitialization(
              amount,
              'USD',
            );
          },
          child: Text('Pay Now ${amount/100} USD'),
        ),
      ),
    );
  }
}
