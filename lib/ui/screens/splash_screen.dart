import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:question_nswer/ui/screens/homepage_screen.dart';
import 'package:question_nswer/ui/screens/login_screen.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Check if the token is stored
    String? token = await _secureStorage.read(key: 'auth_token');
    
    // If token is found, navigate to the Homepage, else to LoginScreen
    if (token != null && token.isNotEmpty) {
      // Token exists, user is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomepageScreen()),
      );
    } else {
      // No token, user is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show loading while checking login status
      ),
    );
  }
}
