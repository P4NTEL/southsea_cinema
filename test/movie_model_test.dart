import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';

void main() {
  group('Movie model tests', () {
    test('creates Movie instance with given properties', () {
      const movie = Movie(
        id: 'how-to-train-your-dragon',
        title: 'How To Train Your Dragon',
        room: 'Room 1',
        agerate: 'PG-13',
        datetime: '18:00 - 20:05 22 Oct 2026',
        adultprice: 7.50,
        image: 'assets/images/httyd.jpg',
        description: 'A young viking changes his opinion about dragons',
      );

      expect(movie.id, 'how-to-train-your-dragon');
      expect(movie.title, 'How To Train Your Dragon');
      expect(movie.room, 'Room 1');
      expect(movie.agerate, 'PG-13');
      expect(movie.datetime, '18:00 - 20:05 22 Oct 2026');
      expect(movie.adultprice, 7.5);
      expect(movie.image, 'assets/images/httyd.jpg');
      expect(movie.description,'A young viking changes his opinion about dragons',);
    });

    test('formattedPrice returns price with pound sign and two decimals', () {
      const movie = Movie(
        id: 'joker',
        title: 'Joker',
        room: 'Room 2',
        agerate: 'R',
        datetime: '19:00 - 21:05 24 Oct 2026',
        adultprice: 7.50,
        image: 'assets/images/joker.jpg',
        description: 'Joker is a gritty psychological thriller exploring the tragic, chaotic descent of failed comedian Arthur Fleck.',
      );

      expect(movie.formattedPrice, '£7.50');
    });
  });
}