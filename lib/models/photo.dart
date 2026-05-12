class Photo {
  final String url;
  final String? title;
  final String? note;
  final String? date;

  Photo({
    required this.url,
    this.title,
    this.note,
    this.date,
  });

  factory Photo.fromMap(Map<String, dynamic> map) {
    // The file URL is the only required field.
    if (map['file'] == null) {
      throw ArgumentError('Photo map must contain a "file" key');
    }

    return Photo(
      url: map['file'],
      title: map['titl'],
      note: map['note'],
      date: map['_date'],
    );
  }
}
