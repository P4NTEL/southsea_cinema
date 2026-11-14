class BookingItem {
  final int? id;
  final int? bookingId;
  final String movieId;
  final String movieTitle;
  final String movieDatetime;
  final double unitPrice;
  final int quantity;

  const BookingItem({
    this.id,
    this.bookingId,
    required this.movieId,
    required this.movieTitle,
    required this.movieDatetime,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  // The parent booking's row id is given when the item is saved.
  Map<String, Object?> toMap(int parentBookingId) {
    final Map<String, Object?> data = <String, Object?>{
      'booking_id': parentBookingId,
      'movie_id': movieId,
      'movie_title': movieTitle,
      'movie_datetime': movieDatetime,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  factory BookingItem.fromMap(Map<String, Object?> map) {
    final num priceNumber = map['unit_price'] as num;
    final double unitPrice = priceNumber.toDouble();

    return BookingItem(
      id: map['id'] as int?,
      bookingId: map['booking_id'] as int?,
      movieId: map['movie_id'] as String,
      movieTitle: map['movie_title'] as String,
      movieDatetime: map['movie_datetime'] as String,
      unitPrice: unitPrice,
      quantity: map['quantity'] as int,
    );
  }
}
