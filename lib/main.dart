import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/features/authentication/controllers/auth_provider.dart';
import 'package:question_nswer/ui/screens/splash_screen.dart';

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
