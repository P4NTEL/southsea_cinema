import 'package:southsea_cinema/models/movie.dart';

class MovieRepository {
  List<Movie> getMovies(){
    return const [
      Movie(
        id: '1',
        title: 'How To Train Your Dragon',
        room: 'Room 1',
        agerate: 'PG-13',
        datetime: '18:00 - 20:05 22 Oct 2026',
        adultprice: 7.50,
        image: 'assets/images/httyd.jpg',
        description: 'A young viking changes his opinion about dragons'
      ),
      Movie(
        id: '2',
        title: 'Joker',
        room: 'Room 2',
        agerate: 'R',
        datetime: '19:00 - 21:05 24 Oct 2026',
        adultprice: 7.50,
        image: 'assets/images/joker.jpg',
        description: 'Joker is a gritty psychological thriller exploring the tragic, chaotic descent of failed comedian Arthur Fleck.'
      )
    ];
  }

}