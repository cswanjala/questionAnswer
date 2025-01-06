import 'package:flutter/material.dart';
import 'package:question_nswer/ui/screens/homepage_screen.dart';


void main() => runApp(AnswersApp());

class AnswersApp extends StatelessWidget {
  const AnswersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Answers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system,
      home: HomepageScreen(),
    );
  }
}


