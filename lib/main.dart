import 'package:flutter/material.dart';
// Assuming the LoginScreen is in the same directory
import 'package:question_nswer/ui/screens/splash_screen.dart';  // Assuming the HomepageScreen is in the same directory

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Just Answer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),  // SplashScreen that decides where to navigate
    );
  }
}

