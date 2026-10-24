import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/screens/menu_screen.dart';
import 'package:southsea_cinema/screens/settings_screen.dart';

void main() {
  testWidgets('MenuScreen shows the movies and the settings button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MenuScreen()));

    expect(find.text('How To Train Your Dragon'), findsOneWidget);
    expect(find.text('Joker'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('Tapping the settings button navigates to SettingsScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) {
            return const MenuScreen();
          },
          '/settings': (BuildContext context) {
            return const SettingsScreen();
          },
        },
      ),
    );

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}