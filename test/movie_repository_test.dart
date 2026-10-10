import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

void main() {
  group('MovieRepository unit tests', () {
    test('getMovies returns at least two movies', () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMovies();

      expect(movies.length, greaterThanOrEqualTo(2));
    });

    test('every movie has a non-empty unique id', () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMovies();
      final Set<String> ids = {};

      for (final movie in movies) {
        expect(movie.id, isNotEmpty);
        expect(ids.contains(movie.id), false);
        ids.add(movie.id);
      }
    });

    test('every movie has a title, age rating and price above zero', () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMovies();

      for (final movie in movies) {
        expect(movie.title, isNotEmpty);
        expect(movie.agerate, isNotEmpty);
        expect(movie.adultprice, greaterThan(0));
      }
    });

    test('getMovieById returns matching movie when id exists', () {
      final MovieRepository repository = MovieRepository();
      final Movie? movie = repository.getMovieById('joker');

      expect(movie, isNotNull);
      expect(movie?.title, 'Joker');
    });

    test('getMovieById returns null when id does not exist', () {
      final MovieRepository repository = MovieRepository();
      final Movie? movie = repository.getMovieById('non-existent');

      expect(movie, isNull);
    });

    test('getMoviesByAgeRating returns only movies with that rating', () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMoviesByAgeRating('PG-13');

      expect(movies.length, 1);
      expect(movies.every((movie) => movie.agerate == 'PG-13'), true);
      expect(movies.first.id, 'how-to-train-your-dragon');
    });

    test('getMoviesByAgeRating returns empty list when none match', () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMoviesByAgeRating('U');

      expect(movies, isEmpty);
    });

    test('getMoviesUnderPrice returns only movies below the price', () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMoviesUnderPrice(8.0);

      expect(movies.length, 2);
      expect(movies.every((movie) => movie.adultprice < 8.0), true);
    });

    test('getMoviesUnderPrice returns empty list when none are cheaper', () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMoviesUnderPrice(7.50);

      expect(movies, isEmpty);
    });
  });
}