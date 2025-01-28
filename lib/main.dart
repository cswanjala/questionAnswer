import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/features/authentication/controllers/auth_provider.dart';
import 'package:question_nswer/core/features/categories/controllers/categories_provider.dart';
import 'package:question_nswer/core/features/experts/controllers/experts_provider.dart';
import 'package:question_nswer/core/features/questions/controllers/questions_provider.dart';
import 'package:question_nswer/core/features/users/controllers/users_provider.dart';
import 'package:question_nswer/ui/screens/splash_screen.dart';
import 'package:question_nswer/core/features/users/controllers/user_messages_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(create: (context) => QuestionsProvider()),
        ChangeNotifierProvider(create: (context) => ExpertsProvider()),
        ChangeNotifierProvider(create: (context) => CategoriesProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Just Answer',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(), // SplashScreen that decides where to navigate
      ),
    );
  }
}
