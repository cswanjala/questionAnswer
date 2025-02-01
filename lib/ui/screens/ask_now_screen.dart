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
  String? _selectedCategory;
  int? _selectedCategoryId;
  final TextEditingController _questionController = TextEditingController();
  File? _selectedImage; // To store the selected image
  bool _isSubmitting = false;
  String _secretKey = "";

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categoriesProvider =
        Provider.of<CategoriesProvider>(context, listen: false);
    await categoriesProvider.fetchCategories();
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

    if (_selectedCategoryId == null || questionContent.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please select a category and enter a question.",
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
      // Step 1: Process the payment
      final paymentSuccess = await _processPayment();
      log("Payment success: $paymentSuccess");

      if (!paymentSuccess) {
        // If payment fails, don't proceed with submitting the question
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

      // Step 2: If payment is successful, submit the question
      final questionsProvider =
          Provider.of<QuestionsProvider>(context, listen: false);
      final success = await questionsProvider.addQuestion(
        questionContent,
        _selectedCategoryId!,
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
          _selectedCategory = null;
          _selectedCategoryId = null;
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
      // Ensure the loading state is reset, even if an error occurs
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
      // Step 1: Fetch the client secret from your backend
      final clientSecret = await _fetchClientSecret();
      log(clientSecret.toString());
      _secretKey = clientSecret.toString();

      log("inside process payment and client secret has been fetched");

      if (clientSecret == null) {
        throw Exception("Failed to fetch client secret.");
      }

      log("before initializing initpayment sheet..");
      // Step 2: Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Cosiwa',
          allowsDelayedPaymentMethods: true,
        ),
      );

      log("after initializing payment sheet");

      // Step 3: Present the payment sheet
      await Stripe.instance.presentPaymentSheet();
      log("payment sheet presented successfully");

      // Step 4: Confirm the payment
      // await Stripe.instance.confirmPaymentSheetPayment();
      // log("payment confirmed successfully");

      return true; // Payment successful
    } on StripeException catch (e) {
      log("Stripe Error: ${e.error.localizedMessage}");
      return false; // Payment failed
    } catch (e) {
      log("Payment Error: $e");
      return false; // Payment failed
    }
  }

  Future<void> _storePaymentDetails() async {
    log("inside store payment details");
  final storage = FlutterSecureStorage();
  
  try {
    // Fetch the payment method details from Stripe
    final paymentMethod = await Stripe.instance.retrievePaymentIntent(_secretKey);

    // Retrieve the user ID from secure storage
    String? userId = await storage.read(key: 'user_id');

    if (userId == null) {
      log("User ID not found in secure storage");
      return; // or handle the error as needed
    }

    // Prepare the payment details to send to the backend
    final paymentDetails = {
      'user_id': userId, // Now using user_id from secure storage
      'stripe_payment_method_id': paymentMethod.id,
      'card_brand': 'visa',
      'card_last4': '456'
    };
    log("amount is $paymentMethod.amount");

    // Send the payment details to the backend
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
      // Call your Django backend to create a PaymentIntent
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
    final categoriesProvider = Provider.of<CategoriesProvider>(context);
    final isSubmitting = Provider.of<QuestionsProvider>(context).isLoading;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose a Category",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (categoriesProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (categoriesProvider.categories.isNotEmpty)
              DropdownButton<String>(
                value: _selectedCategory,
                hint: const Text("Select a category"),
                isExpanded: true,
                items: categoriesProvider.categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedCategoryId = categoriesProvider.categories
                        .firstWhere(
                            (category) => category['name'] == value)['id'];
                  });
                },
              )
            else
              const Text("No categories available."),
            const SizedBox(height: 16),
            const Text(
              "Ask Your Question",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
