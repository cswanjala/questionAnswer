import 'package:flutter/material.dart';
import 'package:question_nswer/ui/screens/chat_screen.dart';
import 'package:question_nswer/ui/screens/homepage_screen.dart';
import 'package:question_nswer/ui/screens/profile_screen.dart';
import 'package:question_nswer/ui/screens/questions_details_screen.dart';
import 'package:question_nswer/ui/screens/post_questions_screen.dart';
import 'package:question_nswer/ui/screens/proposals_screen.dart';
import 'package:question_nswer/ui/screens/contracts_screen.dart';
import 'package:question_nswer/ui/screens/alerts_screen.dart';
import 'package:question_nswer/ui/screens/message_screen.dart';
import 'package:question_nswer/ui/screens/experts_screen.dart';
import 'package:question_nswer/ui/screens/ask_now_screen.dart';
import 'package:question_nswer/ui/screens/login_screen.dart';
import 'package:question_nswer/ui/screens/signup_screen.dart';
import 'package:question_nswer/ui/screens/splash_screen.dart';

void main() => runApp(AnswersApp());

class AnswersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Answers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomepageScreen(),
    );
  }
}


