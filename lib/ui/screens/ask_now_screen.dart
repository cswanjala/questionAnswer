import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:question_nswer/core/features/questions/controllers/questions_provider.dart';
import 'package:question_nswer/core/features/categories/controllers/categories_provider.dart';

class AskNowScreen extends StatefulWidget {
  const AskNowScreen({Key? key}) : super(key: key);

  @override
  _AskNowScreenState createState() => _AskNowScreenState();
}

class _AskNowScreenState extends State<AskNowScreen> {
  final TextEditingController _questionController = TextEditingController();
  File? _selectedImage; // To store the selected image
  bool _isSubmitting = false;
  String _secretKey = "";
  String _paymentMethod = 'stripe'; // Default payment method

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitQuestion() async {
    final questionContent = _questionController.text.trim();

    if (questionContent.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a question.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      log("Before processing payment");
      bool paymentSuccess = false;

      if (_paymentMethod == 'stripe') {
        paymentSuccess = await _processPayment();
      } else if (_paymentMethod == 'infura') {
        paymentSuccess = await _processInfuraPayment();
      }

      log("Payment success: $paymentSuccess");

      if (!paymentSuccess) {
        Fluttertoast.showToast(
          msg: "Payment failed. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      log("Before submitting question");

      final questionsProvider =
          Provider.of<QuestionsProvider>(context, listen: false);
      final success = await questionsProvider.addQuestion(
        questionContent,
        image: _selectedImage,
      );

      log("After submitting question. Success: $success");

      if (success) {
        await _storePaymentDetails();
        Fluttertoast.showToast(
          msg: "Question submitted successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        _questionController.clear();
        setState(() {
          _selectedImage = null;
        });
      } else {
        Fluttertoast.showToast(
          msg: "Failed to submit question.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      log("Error during question submission: $e");
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool> _processPayment() async {
    try {
      log("inside process payment");
      final clientSecret = await _fetchClientSecret();
      log(clientSecret.toString());
      _secretKey = clientSecret.toString();

      log("inside process payment and client secret has been fetched");

      if (clientSecret == null) {
        throw Exception("Failed to fetch client secret.");
      }

      log("before initializing initpayment sheet..");
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Cosiwa',
          allowsDelayedPaymentMethods: true,
        ),
      );

      log("after initializing payment sheet");

      await Stripe.instance.presentPaymentSheet();
      log("payment sheet presented successfully");

      return true; // Payment successful
    } on StripeException catch (e) {
      log("Stripe Error: ${e.error.localizedMessage}");
      return false; // Payment failed
    } catch (e) {
      log("Payment Error: $e");
      return false; // Payment failed
    }
  }

  Future<bool> _processInfuraPayment() async {
    try {
      log("inside process Infura payment");

      final storage = FlutterSecureStorage();
      String? userAddress = 'userAddress';
      String? privateKey = 'private key';

      if (userAddress == null || privateKey == null) {
        throw Exception("User address or private key not found in secure storage");
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.127:8000/api/infura/create-payment/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': 0.01,
          'user_address': userAddress,
          'private_key': privateKey,
          'recipient_address': 'RECIPIENT_ETH_ADDRESS',
        }),
      );

      if (response.statusCode == 200) {
        log("Infura payment processed successfully.");
        return true; // Payment successful
      } else {
        log("Failed to process Infura payment: ${response.body}");
        return false; // Payment failed
      }
    } catch (e) {
      log("Infura Payment Error: $e");
      return false; // Payment failed
    }
  }

  Future<void> _storePaymentDetails() async {
    log("inside store payment details");
    final storage = FlutterSecureStorage();
  
    try {
      final paymentMethod = await Stripe.instance.retrievePaymentIntent(_secretKey);
      String? userId = await storage.read(key: 'user_id');

      if (userId == null) {
        log("User ID not found in secure storage");
        return;
      }

      final paymentDetails = {
        'user_id': userId,
        'stripe_payment_method_id': paymentMethod.id,
        'card_brand': 'visa',
        'card_last4': '456'
      };
      log("amount is $paymentMethod.amount");

      final response = await http.post(
        Uri.parse('http://192.168.1.127:8000/api/store-payment-details/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(paymentDetails),
      );

      if (response.statusCode == 201) {
        log("Payment details stored successfully.");
      } else {
        log("Failed to store payment details: ${response.body}");
      }
    } catch (e) {
      log("Error storing payment details: $e");
    }
  }

  Future<String> _fetchClientSecret() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.127:8000/api/payments/create-intent/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      log(response.body + " and status code " + response.statusCode.toString());

      if (response.statusCode == 200) {
        log("Client secret fetched successfully. at 200 status code");
        final data = jsonDecode(response.body);
        log("data decoded successfully");
        log(data.toString());
        return data['clientSecret'];
      } else {
        throw Exception("Failed to fetch client secret.");
      }
    } catch (e) {
      log("Error fetching client secret: $e");
      return "null";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = Provider.of<QuestionsProvider>(context).isLoading;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ask Your Question",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  TextField(
                    controller: _questionController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: "Type your question here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                    ),
                    textAlignVertical: TextAlignVertical.top,
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Icon(
                        Icons.image,
                        size: 28,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Choose Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _paymentMethod,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: 'stripe',
                  child: Text('Stripe'),
                ),
                DropdownMenuItem(
                  value: 'infura',
                  child: Text('Infura'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _isSubmitting ? null : _submitQuestion,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _isSubmitting
                        ? LinearGradient(colors: [Colors.grey, Colors.grey])
                        : LinearGradient(
                            colors: [Colors.blue, Colors.lightBlueAccent]),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      if (!_isSubmitting)
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          "Submit Question",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
