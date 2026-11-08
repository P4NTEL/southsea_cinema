import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';

const Movie testMovie1 = Movie(
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

void main() {
  setUp(() {
    BasketRepository.instance.clear();
  });

  group('BasketRepository tests', () {
    test('starts with empty basket and zero totals', () {
      final BasketRepository basket = BasketRepository.instance;
      expect(basket.getItems().length, 0);
      expect(basket.getTotalItems(), 0);
      expect(basket.totalItemCount, 0);
      expect(basket.getSubtotal(), 0.0);
      expect(basket.getServiceCharge(), 0.0);
      expect(basket.getTotalDue(), 0.0);
    });

    test('adds items and calculates subtotal and service charge correctly', () {
      final BasketRepository basket = BasketRepository.instance;
      const BasketItem item1 = BasketItem(
        movie: testMovie1,
        quantity: 2,
      );
      const BasketItem item2 = BasketItem(
        movie: testMovie2,
        quantity: 1,
      );

      basket.addItem(item1);
      basket.addItem(item2);

      expect(basket.getItems().length, 2);
      expect(basket.getTotalItems(), 3);
      expect(basket.totalItemCount, 3);
      expect(basket.getSubtotal(), 26.0);
      expect(basket.getServiceCharge(), 4.00);
      expect(basket.getTotalDue(), 30.00);
    });

    test('removes items correctly', () {
      final BasketRepository basket = BasketRepository.instance;
      const BasketItem item = BasketItem(
        movie: testMovie1,
        quantity: 1,
      );
      basket.addItem(item);
      expect(basket.getItems().length, 1);

      basket.removeItem(0);
      expect(basket.getItems().length, 0);
      expect(basket.getTotalDue(), 0.0);
    });
  });
}
