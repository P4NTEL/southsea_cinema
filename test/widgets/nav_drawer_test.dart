import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

Widget buildApp() {
  return MaterialApp(
    initialRoute: '/start',
    routes: <String, WidgetBuilder>{
      '/start': (BuildContext context) {
        return Scaffold(
          appBar: AppBar(),
          drawer: const NavDrawer(),
          body: const Text('Start page'),
        );
      },
      '/': (BuildContext context) {
        return const Scaffold(body: Text('Home page'));
      },
      '/basket': (BuildContext context) {
        return const Scaffold(body: Text('Basket page'));
      },
      '/settings': (BuildContext context) {
        return const Scaffold(body: Text('Settings page'));
      },
    },
  );
}

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('The drawer shows the title and the three pages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openDrawer(tester);

    expect(find.text(appTitle), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('My Basket'), findsOneWidget);
    expect(find.text('My Settings'), findsOneWidget);
  });

  testWidgets('The close button closes the drawer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openDrawer(tester);
    expect(find.text('My Basket'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('My Basket'), findsNothing);
    expect(find.text('Start page'), findsOneWidget);
  });

  testWidgets('Tapping Home opens the home page', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await openDrawer(tester);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Home page'), findsOneWidget);
  });

  testWidgets('Tapping My Basket opens the basket page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openDrawer(tester);

    await tester.tap(find.text('My Basket'));
    await tester.pumpAndSettle();

    expect(find.text('Basket page'), findsOneWidget);
  });

  testWidgets('Tapping My Settings opens the settings page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openDrawer(tester);

    await tester.tap(find.text('My Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings page'), findsOneWidget);
  });

  testWidgets('A drawer entry without a page just closes the drawer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          drawer: const Drawer(child: DrawerTile(title: 'No page')),
          body: const Text('Plain page'),
        ),
      ),
    );
    await openDrawer(tester);
    expect(find.text('No page'), findsOneWidget);

    await tester.tap(find.text('No page'));
    await tester.pumpAndSettle();

    expect(find.text('No page'), findsNothing);
    expect(find.text('Plain page'), findsOneWidget);
  });
}
