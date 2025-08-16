import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyRecipeBookApp(initialUserName: null, initialLanguageCode: 'ko'));

    // Verify that the app starts and finds a MaterialApp widget.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}