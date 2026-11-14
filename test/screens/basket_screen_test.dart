import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/screens/basket_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const Movie testMovie = Movie(
  id: 'test-movie-1',
  title: 'Test Movie One',
  room: 'Room 1',
  agerate: 'PG',
  datetime: '18:00 - 20:00 22 Oct 2026',
  adultprice: 10.0,
  image: 'assets/images/test1.jpg',
  description: 'A test movie.',
);

const Movie testMovie2 = Movie(
  id: 'test-movie-2',
  title: 'Test Movie Two',
  room: 'Room 2',
  agerate: '15',
  datetime: '19:00 - 21:00 23 Oct 2026',
  adultprice: 6.0,
  image: 'assets/images/test2.jpg',
  description: 'Another test movie.',
);

const Movie testMovie3 = Movie(
  id: 'test-movie-3',
  title: 'Test Movie Three',
  room: 'Room 3',
  agerate: 'U',
  datetime: '20:00 - 22:00 24 Oct 2026',
  adultprice: 8.0,
  image: 'assets/images/test3.jpg',
  description: 'A third test movie.',
);

// The basket page is taller than the default 800x600 test window, so a taller
// window lets the buttons be tapped without scrolling.
void useTallWindow(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() async {
    BasketRepository.instance.clear();
    sqfliteFfiInit();
    final Database database = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: CinemaDatabase.instance.configureDatabase,
        onCreate: CinemaDatabase.instance.createTables,
      ),
    );
    CinemaDatabase.instance.setDatabase(database);
  });

  tearDown(() async {
    await CinemaDatabase.instance.close();
  });

  testWidgets('BasketScreen displays empty message when basket has no items', (
    WidgetTester tester,
  ) async {
    useTallWindow(tester);
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: BasketScreen()));
      await tester.pumpAndSettle();
    });
    await tester.pump();

    expect(find.text('Your basket is empty'), findsOneWidget);
    expect(find.text('BUY TICKETS'), findsNothing);
    expect(find.text('No bookings yet'), findsOneWidget);
  });

  testWidgets(
    'BasketScreen renders items and removes item when delete pressed',
    (WidgetTester tester) async {
      useTallWindow(tester);
      const BasketItem item = BasketItem(
        movie: testMovie,
        quantity: 2,
      );
      BasketRepository.instance.addItem(item);

      await tester.runAsync(() async {
        await tester.pumpWidget(const MaterialApp(home: BasketScreen()));
        await tester.pumpAndSettle();
      });
      await tester.pump();

      expect(find.text('MY ORDER'), findsOneWidget);
      expect(find.text('2 Tickets'), findsOneWidget);
      expect(find.text('£20.00'), findsWidgets);
      expect(find.text('BUY TICKETS'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(find.text('Your basket is empty'), findsOneWidget);
    },
  );

  testWidgets('Checkout saves a booking, clears the basket and lists it', (
    WidgetTester tester,
  ) async {
    useTallWindow(tester);
    BasketRepository.instance.addItem(
      const BasketItem(movie: testMovie, quantity: 2),
    );
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: BasketScreen()));
      await tester.pumpAndSettle();
    });
    await tester.pump();

    await tester.runAsync(() async {
      await tester.tap(find.text('BUY TICKETS'));
      await tester.pumpAndSettle();
    });
    await tester.pumpAndSettle();

    final List<Booking>? bookings = await tester.runAsync(() async {
      return await CinemaDatabase.instance.getAllBookings();
    });
    await tester.pumpAndSettle();

    expect(bookings, isNotNull);
    if (bookings != null) {
      expect(bookings.length, 1);
      expect(bookings[0].bookingNumber, 1001);
      expect(bookings[0].summary, '2 x Test Movie One');
      expect(bookings[0].total, 24.00);
    }
    expect(BasketRepository.instance.getItems(), isEmpty);
    expect(find.text('Booking 1001 saved'), findsOneWidget);
    expect(find.text('Booking #1001'), findsOneWidget);
  });

  testWidgets('Checkout saves each film as an item and lists it', (
    WidgetTester tester,
  ) async {
    useTallWindow(tester);
    BasketRepository.instance.addItem(
      const BasketItem(movie: testMovie, quantity: 2),
    );
    BasketRepository.instance.addItem(
      const BasketItem(movie: testMovie2, quantity: 3),
    );
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: BasketScreen()));
      await tester.pumpAndSettle();
    });
    await tester.pump();

    await tester.runAsync(() async {
      await tester.tap(find.text('BUY TICKETS'));
      await tester.pumpAndSettle();
    });
    await tester.pumpAndSettle();

    final List<BookingItem>? items = await tester.runAsync(() async {
      final List<Booking> bookings =
          await CinemaDatabase.instance.getAllBookings();
      final int? bookingId = bookings[0].id;
      if (bookingId == null) {
        return <BookingItem>[];
      }
      return await CinemaDatabase.instance.getBookingItems(bookingId);
    });
    await tester.pumpAndSettle();

    expect(items, isNotNull);
    if (items != null) {
      expect(items.length, 2);
      expect(items[0].movieTitle, 'Test Movie One');
      expect(items[0].quantity, 2);
      expect(items[1].movieTitle, 'Test Movie Two');
      expect(items[1].quantity, 3);
    }
    expect(
      find.text(
        '2 x Test Movie One at 18:00 - 20:00 22 Oct 2026'
        ' - £10.00 each: £20.00',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        '3 x Test Movie Two at 19:00 - 21:00 23 Oct 2026'
        ' - £6.00 each: £18.00',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Checkout keeps the basket when saving fails', (
    WidgetTester tester,
  ) async {
    useTallWindow(tester);
    BasketRepository.instance.addItem(
      const BasketItem(movie: testMovie, quantity: 2),
    );

    await tester.runAsync(() async {
      final Database database = await CinemaDatabase.instance.database;
      await database.execute('DROP TABLE bookings');
    });

    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: BasketScreen()));
      await tester.pumpAndSettle();
    });
    await tester.pump();

    await tester.runAsync(() async {
      await tester.tap(find.text('BUY TICKETS'));
      await tester.pumpAndSettle();
    });
    await tester.pumpAndSettle();

    expect(BasketRepository.instance.getItems().length, 1);
    expect(find.text('2 Tickets'), findsOneWidget);
    expect(find.textContaining('Could not save your booking'), findsOneWidget);
  });

  testWidgets('BasketScreen lists past bookings newest-first', (
    WidgetTester tester,
  ) async {
    useTallWindow(tester);
    await tester.runAsync(() async {
      await CinemaDatabase.instance.insertBooking(
        const Booking(
          bookingNumber: 1001,
          summary: '1 x Joker',
          total: 7.50,
          date: '01/01/2026 10:00',
        ),
      );
      await CinemaDatabase.instance.insertBooking(
        const Booking(
          bookingNumber: 1002,
          summary: '2 x How To Train Your Dragon',
          total: 15.00,
          date: '02/01/2026 11:00',
        ),
      );
      await tester.pumpWidget(const MaterialApp(home: BasketScreen()));
      await tester.pumpAndSettle();
    });
    await tester.pump();

    expect(find.text('Booking #1002'), findsOneWidget);
    expect(find.text('Booking #1001'), findsOneWidget);
    expect(find.text('2 x How To Train Your Dragon'), findsOneWidget);
    final double newestY = tester.getTopLeft(find.text('Booking #1002')).dy;
    final double oldestY = tester.getTopLeft(find.text('Booking #1001')).dy;
    expect(newestY, lessThan(oldestY));
  });

  testWidgets('Deleting the middle film leaves the other two', (
    WidgetTester tester,
  ) async {
    useTallWindow(tester);
    BasketRepository.instance.addItem(
      const BasketItem(movie: testMovie, quantity: 1),
    );
    BasketRepository.instance.addItem(
      const BasketItem(movie: testMovie2, quantity: 1),
    );
    BasketRepository.instance.addItem(
      const BasketItem(movie: testMovie3, quantity: 1),
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: BasketScreen()));
      await tester.pumpAndSettle();
    });
    await tester.pump();

    expect(find.textContaining('Test Movie One'), findsOneWidget);
    expect(find.textContaining('Test Movie Two'), findsOneWidget);
    expect(find.textContaining('Test Movie Three'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete_test-movie-2')));
    await tester.pump();

    expect(find.textContaining('Test Movie One'), findsOneWidget);
    expect(find.textContaining('Test Movie Two'), findsNothing);
    expect(find.textContaining('Test Movie Three'), findsOneWidget);
    expect(BasketRepository.instance.getItems().length, 2);
  });
}
