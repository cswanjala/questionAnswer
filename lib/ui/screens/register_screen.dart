import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:question_nswer/ui/screens/login_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isExpert = false; // Tracks whether the user is an expert

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Are you an expert?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isExpert,
                    onChanged: (value) {
                      setState(() {
                        isExpert = value;
                      });
                    },
                    activeColor: Colors.blue,
                    inactiveThumbColor: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Register",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
=======
import 'package:provider/provider.dart';
import 'package:question_nswer/core/features/authentication/controllers/auth_provider.dart';
import 'homepage_screen.dart';

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

  Future<void> _register(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    final isRegistered = await authProvider.register(username, email, password, confirmPassword);
    if (isRegistered) {
      final isLoggedIn = await authProvider.login(username, password);
      if (isLoggedIn) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomepageScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'just',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      TextSpan(
                        text: 'Answer',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Text(
                  'Create a new account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
                SizedBox(height: 40),
                _buildTextField(_usernameController, "Username"),
                SizedBox(height: 20),
                _buildTextField(_emailController, "Email Address", keyboardType: TextInputType.emailAddress),
                SizedBox(height: 20),
                _buildTextField(_passwordController, "Password", obscureText: true),
                SizedBox(height: 20),
                _buildTextField(_confirmPasswordController, "Confirm Password", obscureText: true),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : () => _register(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: authProvider.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Register',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Log in',
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
>>>>>>> app_modularization
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue), borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
>>>>>>> app_modularization
