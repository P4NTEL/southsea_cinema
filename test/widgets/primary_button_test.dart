import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';
 
void main() {
  testWidgets('PrimaryButton renders its label', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Book',
            onPressed: () {},
          ),
        ),
      ),
    );
 
    expect(find.text('Book'), findsOneWidget);
  });
 
  testWidgets('PrimaryButton invokes onPressed when tapped',
      (WidgetTester tester) async {
    bool wasPressed = false;
 
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Book',
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      ),
    );
 
    await tester.tap(find.text('Book'));
    await tester.pump();
 
    expect(wasPressed, isTrue);
  });
}