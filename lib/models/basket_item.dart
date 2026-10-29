import 'package:southsea_cinema/models/movie.dart';

class BasketItem {
  final Movie movie;
  final int quantity;

  const BasketItem({required this.movie, required this.quantity});

  double get lineTotal => movie.adultprice * quantity;
}
