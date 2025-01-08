import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:question_nswer/main.dart';
import 'package:question_nswer/ui/screens/register_screen.dart';

void main() {
  testWidgets('AnswersApp loads RegisterPage as the initial screen', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const AnswersApp());

    // Verify the RegisterPage widget is displayed
    expect(find.byType(RegisterPage), findsOneWidget);

    // Verify UI elements in the RegisterPage
    expect(find.text('Register'), findsWidgets); // Replace 'Register' with actual text in RegisterPage
    expect(find.byType(TextFormField), findsWidgets); // Check for text input fields
    expect(find.byType(ElevatedButton), findsWidgets); // Check for buttons
  });

  testWidgets('Theme is applied correctly', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const AnswersApp());

    // Verify theme is applied (primary color check)
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.primarySwatch, Colors.blue);
  });
}

extension on ThemeData? {
   get primarySwatch => null;
}
