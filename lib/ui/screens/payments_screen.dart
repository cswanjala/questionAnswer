import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:question_nswer/keys.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int amount = 2000;

  Map<String, dynamic>? intentPaymentData;

  showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        intentPaymentData = null;
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
        'amount': amountInCents.toString(),  // Stripe expects the amount in the smallest currency unit
        'currency': currency,
        'automatic_payment_methods[enabled]': 'true',  // Add automatic payment methods enabled
      };

      var responseFromStripeApi = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: paymentInfo,
        headers: {
          "Authorization": "Bearer $SecretKey",  // Use your Stripe Secret Key
          "Content-Type": "application/x-www-form-urlencoded",  // Correct Content-Type
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

  // Function to call backend API and create payment intent
  Future<void> createPaymentIntent() async {
    try {
      // Call the backend to create a PaymentIntent
      final response = await http.post(
        Uri.parse('http://192.168.1.127:8000/api/payments/create-intent/'),
      );

      final responseData = json.decode(response.body);
      final clientSecret = responseData['client_secret'];

      // Set up the payment sheet configuration
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.light,
          merchantDisplayName: 'Cosiwa',
        ),
      );

      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Successful!')));
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed')));
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
          child: Text('Pay Now $amount USD'),
        ),
      ),
    );
  }
}