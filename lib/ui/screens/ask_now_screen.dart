import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/features/questions/controllers/questions_provider.dart';
import 'package:question_nswer/core/features/categories/controllers/categories_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:question_nswer/keys.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
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

    log("before payment");

    // First, try to process the payment
    final paymentSuccess = await _processPayment();
    log("Payment Success: $paymentSuccess");

    if (!paymentSuccess) {
      // If payment fails, don't proceed with submitting the question
      Fluttertoast.showToast(
        msg: "Payment failed. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    // If payment is successful, proceed to submit the question
    final questionsProvider = Provider.of<QuestionsProvider>(context, listen: false);
    final success = await questionsProvider.addQuestion(
      questionContent,
      _selectedCategoryId!,
      image: _selectedImage,
    );

    if (success) {
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

    setState(() {
      _isSubmitting = false;
    });
  }

  Future<bool> _processPayment() async {
    try {
      // Initialize the payment sheet
      await paymentSheetInitialization(5, 'USD'); // You can customize the amount here

      // Show the payment sheet
      await showPaymentSheet();

      // If the payment was successful, return true
      return true;
    } catch (e) {
      // Handle any errors that occur during the payment process
      log("Payment Error: $e");
      return false;
    }
  }

  // Function to initialize and show the payment sheet
  Future<void> paymentSheetInitialization(int amountToBeCharged, String currency) async {
    try {
      final intentPaymentData = await makeIntentForPayment(amountToBeCharged, currency);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret: intentPaymentData['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'Cosiwa',
        ),
      );
    } catch (errorMsg, s) {
      log(s.toString());
      log(errorMsg.toString());
    }
  }

  // Function to create payment intent using your backend API
  Future<Map<String, dynamic>> makeIntentForPayment(int amountToBeCharged, String currency) async {
    try {
      // Convert the amount to cents (if it's in dollars, for example, $20 becomes 2000 cents)
      int amountInCents = amountToBeCharged * 100;

      // Prepare the form data for the request
      Map<String, String> paymentInfo = {
        'amount': amountInCents.toString(),
        'currency': currency,
        'automatic_payment_methods[enabled]': 'true',
      };

      var responseFromStripeApi = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: paymentInfo,
        headers: {
          "Authorization": "Bearer $SecretKey",  // Use your Stripe Secret Key
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      return jsonDecode(responseFromStripeApi.body);
    } catch (errorMsg, s) {
      log(s?.toString() ?? 'Unknown Error');
      log(errorMsg?.toString() ?? 'Unknown Error');
      rethrow;
    }
  }

  // Function to show the payment sheet
  Future<void> showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        // Payment is successful, return to the main flow
        print('Payment Successful');
      });
    } on StripeException catch (e) {
      // Handle Stripe errors
      print('Stripe error: ${e.error.localizedMessage}');
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Error'),
          content: Text("Cancelled"),
        ),
      );
    } catch (errorMsg) {
      print('Unknown error: $errorMsg');
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
                        .firstWhere((category) => category['name'] == value)['id'];
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
                        : LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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