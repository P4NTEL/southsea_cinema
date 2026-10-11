import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/screens/menu_screen.dart';
import 'package:southsea_cinema/views/movie_listing.dart';

// The listing page is not scrollable, so the default 800x600 test window is
// too short for it. A taller window stops the layout from overflowing.
void useTallWindow(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('App smoke tests', () {
    testWidgets('App displays MenuScreen as home', (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      expect(find.byType(MenuScreen), findsOneWidget);
      expect(find.text('Southsea Cinema'), findsOneWidget);
    });

    testWidgets('Displays movie titles', (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      expect(find.text('How To Train Your Dragon'), findsOneWidget);
      expect(find.text('Joker'), findsOneWidget);
    });

    testWidgets('Displays a booking button on each movie card',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      expect(find.text('BOOK NOW'), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('Tapping the first booking button opens its movie listing',
        (WidgetTester tester) async {
      useTallWindow(tester);
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(MovieListing), findsOneWidget);
      expect(find.text('How To Train Your Dragon'), findsOneWidget);
      expect(find.text('Room 1'), findsOneWidget);
      expect(find.text('Adult (£7.50)'), findsOneWidget);
    });

    testWidgets('Tapping the second booking button opens that movie listing',
        (WidgetTester tester) async {
      useTallWindow(tester);
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      expect(find.byType(MovieListing), findsOneWidget);
      expect(find.text('Joker'), findsOneWidget);
      expect(find.text('Room 2'), findsOneWidget);
    });

    testWidgets('Add to order shows a confirmation message',
        (WidgetTester tester) async {
      useTallWindow(tester);
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to order'));
      await tester.pumpAndSettle();

      expect(find.text('Added 1 ticket(s) to your order'), findsOneWidget);
    });
  });
}