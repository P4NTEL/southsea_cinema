import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUp(() async {
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

  Booking buildBooking(int bookingNumber, String summary, double total) {
    return Booking(
      bookingNumber: bookingNumber,
      summary: summary,
      total: total,
      date: '01/01/2026 10:00',
    );
  }

  BookingItem buildItem(String title, int quantity) {
    return BookingItem(
      movieId: 'movie-1',
      movieTitle: title,
      movieDatetime: 'Sunday 4 Oct 2026 15:00',
      unitPrice: 6.0,
      quantity: quantity,
    );
  }

  test('insertBooking stores a booking and returns its id', () async {
    final int id = await CinemaDatabase.instance.insertBooking(
      buildBooking(1001, '1 x Joker', 7.50),
    );
    expect(id, greaterThan(0));

    final List<Booking> bookings =
        await CinemaDatabase.instance.getAllBookings();
    expect(bookings.length, 1);
    expect(bookings[0].id, id);
    expect(bookings[0].summary, '1 x Joker');
    expect(bookings[0].total, 7.50);
  });

  test('getNextBookingNumber increments the current maximum', () async {
    expect(await CinemaDatabase.instance.getNextBookingNumber(), 1001);

    await CinemaDatabase.instance.insertBooking(
      buildBooking(1005, 'Booking', 5.0),
    );
    expect(await CinemaDatabase.instance.getNextBookingNumber(), 1006);
  });

  test('getAllBookings returns newest booking number first', () async {
    await CinemaDatabase.instance.insertBooking(
      buildBooking(1001, 'First', 5.0),
    );
    await CinemaDatabase.instance.insertBooking(
      buildBooking(1003, 'Third', 9.0),
    );
    await CinemaDatabase.instance.insertBooking(
      buildBooking(1002, 'Second', 7.0),
    );

    final List<Booking> bookings =
        await CinemaDatabase.instance.getAllBookings();
    expect(bookings[0].bookingNumber, 1003);
    expect(bookings[1].bookingNumber, 1002);
    expect(bookings[2].bookingNumber, 1001);
  });

  test('insertBooking saves the booking and all its items together', () async {
    final int id = await CinemaDatabase.instance.insertBooking(
      buildBooking(1001, '2 x Film One, 3 x Film Two', 30.0),
      items: [buildItem('Film One', 2), buildItem('Film Two', 3)],
    );

    final Database db = await CinemaDatabase.instance.database;
    final List<Map<String, Object?>> bookingRows = await db.query('bookings');
    final List<Map<String, Object?>> itemRows = await db.query('booking_items');
    expect(bookingRows.length, 1);
    expect(itemRows.length, 2);

    final List<BookingItem> items =
        await CinemaDatabase.instance.getBookingItems(id);
    expect(items.length, 2);
    expect(items[0].movieTitle, 'Film One');
    expect(items[0].quantity, 2);
    expect(items[0].unitPrice, 6.0);
    expect(items[0].bookingId, id);
    expect(items[1].movieTitle, 'Film Two');
    expect(items[1].quantity, 3);
  });

  test('getBookingItems only returns the items of that booking', () async {
    final int firstId = await CinemaDatabase.instance.insertBooking(
      buildBooking(1001, 'First', 12.0),
      items: [buildItem('Film One', 2)],
    );
    final int secondId = await CinemaDatabase.instance.insertBooking(
      buildBooking(1002, 'Second', 18.0),
      items: [buildItem('Film Two', 3)],
    );

    final List<BookingItem> firstItems =
        await CinemaDatabase.instance.getBookingItems(firstId);
    final List<BookingItem> secondItems =
        await CinemaDatabase.instance.getBookingItems(secondId);
    expect(firstItems.length, 1);
    expect(firstItems[0].movieTitle, 'Film One');
    expect(secondItems.length, 1);
    expect(secondItems[0].movieTitle, 'Film Two');
  });

  test('A failed item insert rolls back the booking', () async {
    // A quantity of 0 breaks the CHECK (quantity > 0) rule on the table.
    await expectLater(
      CinemaDatabase.instance.insertBooking(
        buildBooking(1001, 'Broken', 12.0),
        items: [buildItem('Film One', 2), buildItem('Film Two', 0)],
      ),
      throwsA(isA<DatabaseException>()),
    );

    final Database db = await CinemaDatabase.instance.database;
    expect(await db.query('bookings'), isEmpty);
    expect(await db.query('booking_items'), isEmpty);
  });

  test('An item for a booking that does not exist is rejected', () async {
    final Database db = await CinemaDatabase.instance.database;

    await expectLater(
      db.insert('booking_items', buildItem('Film One', 1).toMap(999)),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('Upgrading a version 1 database keeps the existing bookings', () async {
    final Directory folder = Directory.systemTemp.createTempSync('cinema_db');
    addTearDown(() {
      folder.deleteSync(recursive: true);
    });
    final String filePath = join(folder.path, 'old_cinema.db');

    // Create a version 1 file that only has the bookings table.
    final Database oldDatabase = await databaseFactoryFfiNoIsolate.openDatabase(
      filePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE bookings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              booking_number INTEGER NOT NULL,
              summary TEXT NOT NULL,
              total REAL NOT NULL,
              date TEXT NOT NULL
            )
          ''');
        },
      ),
    );
    await oldDatabase.insert('bookings', <String, Object?>{
      'booking_number': 1001,
      'summary': '1 x Joker',
      'total': 7.50,
      'date': '01/01/2026 10:00',
    });
    await oldDatabase.insert('bookings', <String, Object?>{
      'booking_number': 1002,
      'summary': '2 x How To Train Your Dragon',
      'total': 15.00,
      'date': '02/01/2026 11:00',
    });
    await oldDatabase.close();

    // Reopen the same file with the app's version 2 setup.
    final Database upgraded = await databaseFactoryFfiNoIsolate.openDatabase(
      filePath,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: CinemaDatabase.instance.configureDatabase,
        onCreate: CinemaDatabase.instance.createTables,
        onUpgrade: CinemaDatabase.instance.upgradeTables,
      ),
    );
    addTearDown(upgraded.close);

    final List<Map<String, Object?>> bookings = await upgraded.query(
      'bookings',
      orderBy: 'booking_number ASC',
    );
    expect(bookings.length, 2);
    expect(bookings[0]['booking_number'], 1001);
    expect(bookings[0]['summary'], '1 x Joker');
    expect(bookings[0]['total'], 7.50);
    expect(bookings[1]['booking_number'], 1002);
    expect(bookings[1]['summary'], '2 x How To Train Your Dragon');
    expect(bookings[1]['total'], 15.00);

    final List<Map<String, Object?>> itemTable = await upgraded.rawQuery(
      "SELECT name FROM sqlite_master WHERE name = 'booking_items'",
    );
    expect(itemTable.length, 1);
    expect(await upgraded.query('booking_items'), isEmpty);

    // The new table works for an old booking.
    final int oldBookingId = bookings[0]['id'] as int;
    await upgraded.insert(
      'booking_items',
      buildItem('Joker', 1).toMap(oldBookingId),
    );
    expect((await upgraded.query('booking_items')).length, 1);
  });
}
