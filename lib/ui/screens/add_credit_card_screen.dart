// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:stripe_payment/stripe_payment.dart';
//
// class AddCreditCardScreen extends StatefulWidget {
//   const AddCreditCardScreen({Key? key}) : super(key: key);
//
//   @override
//   _AddCreditCardScreenState createState() => _AddCreditCardScreenState();
// }
//
// class _AddCreditCardScreenState extends State<AddCreditCardScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _cardNumberController = TextEditingController();
//   final TextEditingController _expiryDateController = TextEditingController();
//   final TextEditingController _cvvController = TextEditingController();
//   final TextEditingController _cardholderNameController = TextEditingController();
//
//   String? _cardType = "Visa"; // Default to Visa
//   final _storage = FlutterSecureStorage();
//
//   @override
//   void initState() {
//     super.initState();
//     StripePayment.setOptions(
//       StripeOptions(
//         publishableKey: "pk_live_51LO4VqIGiXYMWiIh4IO9jvDPsF2wvSTNmc1WrVUWTvHtcSJproiQrmKtwbMB30d3DMDv9h8PV8MpdWdDMFo41y1Y0081LUIuET", // Replace with your Stripe publishable key
//         merchantId: "Test", // Optional
//         androidPayMode: 'test', // Optional
//       ),
//     );
//   }
//
//   // Function to handle form submission
//   Future<void> _submitCardDetails() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       final cardNumber = _cardNumberController.text.replaceAll(' ', '');
//       final expiryDate = _expiryDateController.text;
//       final cvv = _cvvController.text;
//       final cardholderName = _cardholderNameController.text;
//
//       // Validate and split expiry date
//       if (expiryDate.length != 4) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Invalid expiry date format. Please use MMYY.')),
//         );
//         return;
//       }
//
//       final expiryMonth = int.parse(expiryDate.substring(0, 2));
//       final expiryYear = int.parse('20' + expiryDate.substring(2));
//
//       final card = CreditCard(
//         number: cardNumber,
//         expMonth: expiryMonth,
//         expYear: expiryYear,
//         cvc: cvv,
//         name: cardholderName,
//       );
//
//       try {
//         final token = await StripePayment.createTokenWithCard(card);
//
//         final cardData = {
//           'token': token.tokenId,
//           'cardholder_name': cardholderName,
//           'card_type': _cardType,
//         };
//
//         final authToken = await _storage.read(key: 'auth_token');
//
//         final response = await http.post(
//           Uri.parse('http://50.6.205.45:8000/api/add_card/'), // Replace with your API URL
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $authToken', // Use the token from secure storage
//           },
//           body: json.encode(cardData),
//         );
//
//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Credit Card Added Successfully!')),
//           );
//           Navigator.pop(context); // Go back to the previous screen
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to add credit card. ' + response.body.toString())),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('An error occurred. Please try again. ' + e.toString())),
//         );
//         log(e.toString());
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Credit Card'),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 20),
//                 // Cardholder Name
//                 TextFormField(
//                   controller: _cardholderNameController,
//                   decoration: InputDecoration(
//                     labelText: 'Cardholder Name',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter the cardholder name';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 // Card Number
//                 TextFormField(
//                   controller: _cardNumberController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: 'Card Number',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.credit_card),
//                   ),
//                   inputFormatters: [
//                     LengthLimitingTextInputFormatter(19), // Limit to 19 characters (for 16-digit card + spaces)
//                     FilteringTextInputFormatter.digitsOnly,
//                     // Format for card number (xxxx xxxx xxxx xxxx)
//                     CardNumberInputFormatter(),
//                   ],
//                   validator: (value) {
//                     if (value == null || value.isEmpty || value.length < 16) {
//                       return 'Please enter a valid card number';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 // Expiry Date
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _expiryDateController,
//                         keyboardType: TextInputType.number, // Allow only numbers
//                         decoration: InputDecoration(
//                           labelText: 'Expiry Date (MMYY)',
//                           border: OutlineInputBorder(),
//                         ),
//                         inputFormatters: [
//                           LengthLimitingTextInputFormatter(4), // Only allow 4 digits for MMYY
//                           FilteringTextInputFormatter.digitsOnly, // Allow only digits
//                         ],
//                         validator: (value) {
//                           if (value == null || value.isEmpty || value.length != 4) {
//                             return 'Please enter a valid expiry date';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 // CVV
//                 TextFormField(
//                   controller: _cvvController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: 'CVV',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.lock),
//                   ),
//                   inputFormatters: [
//                     LengthLimitingTextInputFormatter(3), // 3 digits for CVV
//                     FilteringTextInputFormatter.digitsOnly,
//                   ],
//                   validator: (value) {
//                     if (value == null || value.isEmpty || value.length < 3) {
//                       return 'Please enter a valid CVV';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 // Card Type Dropdown (Optional)
//                 DropdownButtonFormField<String>(
//                   value: _cardType,
//                   items: ['Visa', 'MasterCard', 'Amex'].map((String card) {
//                     return DropdownMenuItem<String>(
//                       value: card,
//                       child: Text(card),
//                     );
//                   }).toList(),
//                   onChanged: (newValue) {
//                     setState(() {
//                       _cardType = newValue;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Card Type',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 30),
//                 // Submit Button
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: _submitCardDetails,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                     ),
//                     child: Text(
//                       'Add Card',
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class CardNumberInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
//     // Format card number with spaces for better user experience
//     String formatted = newValue.text.replaceAll(' ', '').replaceAllMapped(
//       RegExp(r'(\d{4})(?=\d)'),
//           (match) => '${match.group(1)} ',
//     );
//     return newValue.copyWith(text: formatted);
//   }
// }