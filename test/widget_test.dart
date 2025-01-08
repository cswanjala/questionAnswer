import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:question_nswer/ui/screens/register_screen.dart';
import 'package:question_nswer/ui/screens/login_screen.dart';

void main() {
  group('RegisterPage Widget Tests', () {
    testWidgets('Verify UI elements on RegisterPage', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Check if "Create Account" text exists
      expect(find.text('Create Account'), findsOneWidget);

      // Check for Email TextField
      expect(find.byType(TextField), findsNWidgets(2)); // Email and Password fields

      // Check for Expert Switch
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Are you an expert?'), findsOneWidget);

      // Check for Register Button
      expect(find.text('Register'), findsOneWidget);

      // Check for Login TextButton
      expect(find.text('Already have an account? Login'), findsOneWidget);
    });

    testWidgets('Toggle Expert Switch', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Verify initial state of the switch
      final switchFinder = find.byType(Switch);
      Switch switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse); // Default value is false

      // Toggle the switch
      await tester.tap(switchFinder);
      await tester.pump();

      // Verify the updated state of the switch
      switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isTrue); // Value should now be true
    });

    testWidgets('Navigate to LoginScreen on Register Button press', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Tap the "Register" button
      final registerButton = find.text('Register');
      await tester.tap(registerButton);
      await tester.pumpAndSettle(); // Wait for navigation to complete

      // Verify navigation to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Navigate to LoginScreen on "Already have an account? Login" press', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // Tap the "Already have an account? Login" text button
      final loginTextButton = find.text('Already have an account? Login');
      await tester.tap(loginTextButton);
      await tester.pumpAndSettle(); // Wait for navigation to complete

      // Verify navigation to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
