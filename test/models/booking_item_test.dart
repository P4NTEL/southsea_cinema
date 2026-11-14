import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking_item.dart';

void main() {
  const BookingItem item = BookingItem(
    movieId: 'movie-1',
    movieTitle: 'Joker',
    movieDatetime: 'Sunday 4 Oct 2026 15:00',
    unitPrice: 6.0,
    quantity: 3,
  );

  test('lineTotal multiplies the unit price by the quantity', () {
    expect(item.lineTotal, 18.0);
  });

  test('toMap uses the column names and the parent booking id', () {
    final Map<String, Object?> map = item.toMap(7);

    expect(map['booking_id'], 7);
    expect(map['movie_id'], 'movie-1');
    expect(map['movie_title'], 'Joker');
    expect(map['movie_datetime'], 'Sunday 4 Oct 2026 15:00');
    expect(map['unit_price'], 6.0);
    expect(map['quantity'], 3);
    expect(map.containsKey('id'), isFalse);
  });

  test('toMap includes the id when the item already has one', () {
    const BookingItem savedItem = BookingItem(
      id: 4,
      movieId: 'movie-1',
      movieTitle: 'Joker',
      movieDatetime: 'Sunday 4 Oct 2026 15:00',
      unitPrice: 6.0,
      quantity: 3,
    );

    expect(savedItem.toMap(7)['id'], 4);
  });

  test('fromMap rebuilds the item, reading whole prices as doubles', () {
    final BookingItem rebuilt = BookingItem.fromMap(<String, Object?>{
      'id': 4,
      'booking_id': 7,
      'movie_id': 'movie-1',
      'movie_title': 'Joker',
      'movie_datetime': 'Sunday 4 Oct 2026 15:00',
      'unit_price': 6,
      'quantity': 3,
    });

    expect(rebuilt.id, 4);
    expect(rebuilt.bookingId, 7);
    expect(rebuilt.movieTitle, 'Joker');
    expect(rebuilt.unitPrice, 6.0);
    expect(rebuilt.quantity, 3);
    expect(rebuilt.lineTotal, 18.0);
  });
}
