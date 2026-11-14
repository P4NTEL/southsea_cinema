import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/movie_listing.dart';

const Movie testMovie = Movie(
  id: 'test-1',
  title: 'Test Movie',
  room: 'Room 1',
  agerate: 'PG',
  datetime: '18:00 22 Oct 2026',
  adultprice: 7.5,
  image: 'assets/images/test.jpg',
  description: 'A test movie.',
);

// The listing switches layout at 600 pixels wide, so each test picks a width.
void useWindowWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> chooseTickets(WidgetTester tester, String quantity) async {
  await tester.tap(find.byType(DropdownMenu<int>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(quantity).last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    BasketRepository.instance.clear();
  });

  testWidgets('Wide layout adds the chosen tickets to the basket', (
    WidgetTester tester,
  ) async {
    useWindowWidth(tester, 800);
    await tester
        .pumpWidget(const MaterialApp(home: MovieListing(movie: testMovie)));
    await tester.pumpAndSettle();

    expect(find.text('Adult (£7.50)'), findsOneWidget);
    await chooseTickets(tester, '3');
    await tester.tap(find.text('Add to order'));
    await tester.pump();

    expect(find.text('Added 3 ticket(s) to your order'), findsOneWidget);
    expect(BasketRepository.instance.getItems().length, 1);
    expect(BasketRepository.instance.getItems()[0].movie.id, 'test-1');
    expect(BasketRepository.instance.getItems()[0].quantity, 3);
  });

  testWidgets('Narrow layout adds the chosen tickets to the basket', (
    WidgetTester tester,
  ) async {
    useWindowWidth(tester, 400);
    await tester
        .pumpWidget(const MaterialApp(home: MovieListing(movie: testMovie)));
    await tester.pumpAndSettle();

    expect(find.text('Adult (£7.50)'), findsOneWidget);
    await chooseTickets(tester, '4');
    await tester.tap(find.text('Add to order'));
    await tester.pump();

    expect(find.text('Added 4 ticket(s) to your order'), findsOneWidget);
    expect(BasketRepository.instance.getItems().length, 1);
    expect(BasketRepository.instance.getItems()[0].quantity, 4);
  });
}
