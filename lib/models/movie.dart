class Movie {
  final String id; 
  final String title;
  final String room;
  final String agerate;
  final String datetime;
  final double adultprice;
  final String image;
  final String description;


const Movie({
    required this.id,
    required this.title,
    required this.room,
    required this.agerate,
    required this.datetime,
    required this.adultprice,
    required this.image,
    required this.description,
  });

  String get formattedPrice => '£${adultprice.toStringAsFixed(2)}';
  bool get isChildFriendly => agerate == 'U' || agerate == 'PG';
  bool get isAdultOnly => agerate == '18';
}