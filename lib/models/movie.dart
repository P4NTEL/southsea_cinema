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

  factory Movie.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String;
    final String title = json['title'] as String;
    final String room = json['room'] as String;
    final String agerate = json['agerate'] as String;
    final String datetime = json['datetime'] as String;
    final num priceNumber = json['adultprice'] as num;
    final double adultprice = priceNumber.toDouble();
    final String image = json['image'] as String;
    final String description = json['description'] as String;

    return Movie(
      id: id,
      title: title,
      room: room,
      agerate: agerate,
      datetime: datetime,
      adultprice: adultprice,
      image: image,
      description: description,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'title': title,
      'room': room,
      'agerate': agerate,
      'datetime': datetime,
      'adultprice': adultprice,
      'image': image,
      'description': description,
    };
    return data;
  }

  String get formattedPrice => '£${adultprice.toStringAsFixed(2)}';
  bool get isChildFriendly => agerate == 'U' || agerate == 'PG';
  bool get isAdultOnly => agerate == '18';
}
