import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:question_nswer/core/features/authentication/controllers/auth_provider.dart';
import 'package:question_nswer/core/features/categories/controllers/categories_provider.dart';
import 'package:question_nswer/core/features/experts/controllers/experts_provider.dart';
import 'package:question_nswer/core/features/experts/controllers/favourite_expert_provider.dart';
import 'package:question_nswer/core/features/questions/controllers/questions_provider.dart';
import 'package:question_nswer/core/features/users/user_provider.dart';
import 'package:question_nswer/keys.dart';
import 'package:question_nswer/ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = PublishableKey;
  await Stripe.instance.applySettings();
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
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (context) => QuestionsProvider()),
        ChangeNotifierProvider(create: (context) => ExpertsProvider()),
        ChangeNotifierProvider(create: (context) => CategoriesProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteExpertsProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'expert ask&more',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(), // SplashScreen that decides where to navigate
      ),
    );
  }
}
