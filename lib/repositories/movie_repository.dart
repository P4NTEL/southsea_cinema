import 'package:southsea_cinema/models/movie.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class MovieRepository {
  List<Movie>? _cachedMovies;

  List<Movie> getMovies() {
    final List<Movie>? cachedMovies = _cachedMovies;
    if (cachedMovies != null) {
      return cachedMovies;
    }
    return const [
      Movie(
          id: 'how-to-train-your-dragon',
          title: 'How To Train Your Dragon',
          room: 'Room 1',
          agerate: 'PG-13',
          datetime: '18:00 - 20:05 22 Oct 2026',
          adultprice: 7.50,
          image: 'assets/images/httyd.jpg',
          description: 'A young viking changes his opinion about dragons'),
      Movie(
          id: 'joker',
          title: 'Joker',
          room: 'Room 2',
          agerate: 'R',
          datetime: '19:00 - 21:05 24 Oct 2026',
          adultprice: 7.50,
          image: 'assets/images/joker.jpg',
          description:
              'Joker is a gritty psychological thriller exploring the tragic, chaotic descent of failed comedian Arthur Fleck.')
    ];
  }

  Movie? getMovieById(String id) {
    for (final movie in getMovies()) {
      if (movie.id == id) {
        return movie;
      }
    }
    return null;
  }

  Future<List<Movie>> loadMoviesFromAsset({
    String assetPath = 'assets/data/movies.json',
  }) async {
    final String jsonString = await rootBundle.loadString(assetPath);
    final dynamic decodedData = jsonDecode(jsonString);
    final List<dynamic> jsonList = decodedData as List<dynamic>;
    final List<Movie> loadedMovies = [];

    for (final dynamic item in jsonList) {
      final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
      final Movie movie = Movie.fromJson(itemMap);
      loadedMovies.add(movie);
    }

    _cachedMovies = loadedMovies;
    return loadedMovies;
  }

  List<Movie> getMoviesByAgeRating(String rating) {
    final List<Movie> matches = [];
    for (final movie in getMovies()) {
      if (movie.agerate == rating) {
        matches.add(movie);
      }
    }
    return matches;
  }

  List<Movie> getMoviesUnderPrice(double maxPrice) {
    final List<Movie> matches = [];
    for (final movie in getMovies()) {
      if (movie.adultprice < maxPrice) {
        matches.add(movie);
      }
    }
    return matches;
  }
}
