import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/services/api_service.dart';

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
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _apiService.fetchCategories();
      log("Categories fetched successfully.");
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load categories: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _submitQuestion() async {
    final questionContent = _questionController.text.trim();
    final token = await const FlutterSecureStorage().read(key: 'auth_token');

    if (_selectedCategoryId == null || questionContent.isEmpty || token == null) {
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
      await _apiService.submitQuestion(questionContent, token, _selectedCategoryId!);
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
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to submit question: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ask Now"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
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
            if (_categories.isNotEmpty)
              DropdownButton<String>(
                value: _selectedCategory,
                hint: const Text("Select a category"),
                isExpanded: true,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedCategoryId = _categories.firstWhere(
                        (category) => category['name'] == value)['id'];
                  });
                },
              )
            else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            const Text(
              "Ask Your Question",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
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
                ),
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isSubmitting ? Colors.grey : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        "Submit Question",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
