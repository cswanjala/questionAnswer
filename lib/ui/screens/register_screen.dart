import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/features/authentication/controllers/auth_provider.dart';
import 'homepage_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  File? _profileImage;
  bool _isExpert = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  List<String> _categories = [];

  /// Picks an image from the gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error selecting image: ${e.toString()}");
    }
  }

  /// Handles user registration
  Future<void> _register(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(msg: "All fields must be filled!");
      return;
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: "Passwords do not match!");
      return;
    }

    // Populate _categories from _categoryController
    if (_isExpert) {
      _categories = _categoryController.text.split(',').map((e) => e.trim()).toList();
    }

    final isRegistered = await authProvider.register(
      username, email, password, confirmPassword, _profileImage, _isExpert, _titleController.text, _categories
    );

    if (isRegistered) {
      final isLoggedIn = await authProvider.login(username, password);
      if (isLoggedIn) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomepageScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'expert',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      TextSpan(
                        text: 'ask&more',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  'Create a new account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey) : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(_usernameController, "Username"),
                const SizedBox(height: 20),
                _buildTextField(_emailController, "Email Address", keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildTextField(_passwordController, "Password", obscureText: true),
                const SizedBox(height: 20),
                _buildTextField(_confirmPasswordController, "Confirm Password", obscureText: true),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Checkbox(
                      value: _isExpert,
                      onChanged: (value) {
                        setState(() {
                          _isExpert = value!;
                        });
                      },
                    ),
                    const Text("Register as Expert"),
                  ],
                ),
                if (_isExpert) ...[
                  _buildTextField(_titleController, "Title"),
                  const SizedBox(height: 20),
                  _buildTextField(_categoryController, "Categories (comma separated)"),
                  const SizedBox(height: 20),
                ],
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : () => _register(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Register',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds text input fields
  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue), borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
