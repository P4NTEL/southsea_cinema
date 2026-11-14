import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';

Movie buildMovie(String agerate) {
  return Movie(
    id: 'movie-$agerate',
    title: 'Test Movie',
    room: 'Room 1',
    agerate: agerate,
    datetime: '18:00 22 Oct 2026',
    adultprice: 7.5,
    image: 'assets/images/test.jpg',
    description: 'A test movie.',
  );
}

void main() {
  test('isChildFriendly is true for U and PG only', () {
    expect(buildMovie('U').isChildFriendly, isTrue);
    expect(buildMovie('PG').isChildFriendly, isTrue);
    expect(buildMovie('12A').isChildFriendly, isFalse);
    expect(buildMovie('18').isChildFriendly, isFalse);
  });

  test('isAdultOnly is true for 18 only', () {
    expect(buildMovie('18').isAdultOnly, isTrue);
    expect(buildMovie('15').isAdultOnly, isFalse);
    expect(buildMovie('U').isAdultOnly, isFalse);
  });
}
