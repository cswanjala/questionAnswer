import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AskNowScreen extends StatefulWidget {
  const AskNowScreen({super.key});

  @override
  _AskNowScreenState createState() => _AskNowScreenState();
}

class _AskNowScreenState extends State<AskNowScreen> {
  String? _selectedCategory;
  int? _selectedCategoryId;
  final TextEditingController _questionController = TextEditingController();
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Fetch categories from the API
  Future<void> _fetchCategories() async {
  final url = Uri.parse('http://192.168.220.229:8000/api/categories/'); // Replace with your API URL
  try {
    final response = await http.get(url);

    // Check if the response status code is successful (2xx)
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _categories = List<Map<String, dynamic>>.from(data);
      });
    } else {
      // Print the raw response body for debugging
      print('Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      // Handle API error
      Fluttertoast.showToast(
        msg: "Failed to load categories (status code: ${response.statusCode})",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } catch (e) {
    // Print error for debugging
    print('Error: $e');
    
    // Handle network error
    Fluttertoast.showToast(
      msg: "Network error from categories: $e",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}


  // Submit the question to the API
  Future<void> _submitQuestion(String questionContent, String token) async {
    if (_selectedCategoryId == null || questionContent.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please select a category and enter a question.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    final url = Uri.parse('http://192.168.220.229:8000/api/questions/'); // Replace with your API URL
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'content': questionContent,
      'category': _selectedCategoryId,
    });

    log("body is $body");

    try {
      final response = await http.post(url, headers: headers, body: body);

    

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final questionId = responseBody['id'];
        final assignedExpert = responseBody['assigned_expert'];

        // Show success toast
        Fluttertoast.showToast(
          msg: "Question successfully added! (ID: $questionId)\nAssigned Expert: $assignedExpert",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        // Show error message from response
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['error'] ?? 'Something went wrong';
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // Handle network error
      Fluttertoast.showToast(
        msg: "Network error from submit question: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Ask Now",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Dropdown
            Text(
              "Choose a Category",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (_categories.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    hint: Text("Select a category"),
                    isExpanded: true,
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['name'], // Category name
                        child: Text(category['name']), // Category name displayed
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        // Get the ID of the selected category
                        _selectedCategoryId = _categories.firstWhere((category) => category['name'] == value)['id'];
                      });
                    },
                  ),
                ),
              )
            else
              CircularProgressIndicator(), // Show loading indicator if categories are still being fetched
            SizedBox(height: 16),

            // Question Input
            Text(
              "Ask Your Question",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Stack(
                children: [
                  TextField(
                    controller: _questionController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: "Type your question here...",
                      contentPadding: EdgeInsets.only(left: 50, top: 10, right: 10, bottom: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: GestureDetector(
                      onTap: () {
                        // Handle attachment click
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Attachment clicked")),
                        );
                      },
                      child: Icon(
                        Icons.attach_file,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final questionContent = _questionController.text;
                  final token = 'your-authentication-token'; // Replace with your token
                  _submitQuestion(questionContent, token);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Send",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
