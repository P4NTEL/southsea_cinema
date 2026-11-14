import 'package:path/path.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
import 'package:sqflite/sqflite.dart';

class CinemaDatabase {
  CinemaDatabase._internal();

  static final CinemaDatabase instance = CinemaDatabase._internal();

  static Database? _database;

  void setDatabase(Database? db) {
    _database = db;
  }

  Future<Database> get database async {
    final Database? cachedDatabase = _database;
    if (cachedDatabase != null) {
      return cachedDatabase;
    }
    final Database db = await _initDB('cinema_data.db');
    _database = db;
    return db;
  }

  Future<Database> _initDB(String fileName) async {
    final String folder = await getDatabasesPath();
    final String filePath = join(folder, fileName);
    final Database db = await openDatabase(
      filePath,
      version: 2,
      onConfigure: configureDatabase,
      onCreate: _createDB,
      onUpgrade: upgradeTables,
    );
    return db;
  }

  // Runs before the tables are created or upgraded. SQLite only enforces
  // foreign keys when this is switched on for each connection.
  Future<void> configureDatabase(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_number INTEGER NOT NULL,
        summary TEXT NOT NULL,
        total REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await _createBookingItemsTable(db);
  }

  // Runs when an existing database file has an older version than the app.
  // It only adds what is missing, so the bookings already saved are kept.
  Future<void> upgradeTables(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createBookingItemsTable(db);
    }
  }

  Future<void> _createBookingItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS booking_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_id INTEGER NOT NULL REFERENCES bookings(id),
        movie_id TEXT NOT NULL,
        movie_title TEXT NOT NULL,
        movie_datetime TEXT NOT NULL,
        unit_price REAL NOT NULL CHECK (unit_price >= 0),
        quantity INTEGER NOT NULL CHECK (quantity > 0)
      )
    ''');
  }

  Future<void> _createDB(Database db, int version) async {
    await createTables(db, version);

    await db.insert('bookings', <String, Object?>{
      'booking_number': 1003,
      'summary': '2 x How To Train Your Dragon',
      'total': 15.00,
      'date': '18/04/2026 12:45',
    });

    await db.insert('bookings', <String, Object?>{
      'booking_number': 1002,
      'summary': '1 x Joker',
      'total': 7.50,
      'date': '02/03/2026 18:10',
    });

    await db.insert('bookings', <String, Object?>{
      'booking_number': 1001,
      'summary': '3 x How To Train Your Dragon',
      'total': 22.50,
      'date': '11/01/2026 13:02',
    });
  }

  // The booking and its items are saved in one transaction, so either all of
  // them are saved or none are.
  Future<int> insertBooking(
    Booking booking, {
    List<BookingItem> items = const [],
  }) async {
    final Database db = await database;
    final int id = await db.transaction((Transaction txn) async {
      final int bookingId = await txn.insert('bookings', booking.toMap());
      for (final BookingItem item in items) {
        await txn.insert('booking_items', item.toMap(bookingId));
      }
      return bookingId;
    });
    return id;
  }

  Future<List<BookingItem>> getBookingItems(int bookingId) async {
    final Database db = await database;
    final List<Map<String, Object?>> records = await db.query(
      'booking_items',
      where: 'booking_id = ?',
      whereArgs: <Object?>[bookingId],
      orderBy: 'id ASC',
    );

    final List<BookingItem> items = [];
    for (final Map<String, Object?> row in records) {
      items.add(BookingItem.fromMap(row));
    }
    return items;
  }

  Future<List<Booking>> getAllBookings() async {
    final Database db = await database;
    final List<Map<String, Object?>> records = await db.query(
      'bookings',
      orderBy: 'booking_number DESC',
    );

    final List<Booking> bookings = [];
    for (final Map<String, Object?> row in records) {
      bookings.add(Booking.fromMap(row));
    }
    return bookings;
  }

  Future<int> getNextBookingNumber() async {
    final Database db = await database;
    final List<Map<String, Object?>> records = await db.rawQuery(
      'SELECT MAX(booking_number) as max_num FROM bookings',
    );

    if (records.isEmpty) {
      return 1001;
    }
    final Object? maxValue = records[0]['max_num'];
    if (maxValue == null) {
      return 1001;
    }

    final int currentMax = maxValue as int;
    return currentMax + 1;
  }

  Future<void> close() async {
    final Database? cachedDatabase = _database;
    if (cachedDatabase != null) {
      await cachedDatabase.close();
      _database = null;
    }
  }
}
