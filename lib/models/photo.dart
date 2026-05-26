import 'package:connectivity_plus/connectivity_plus.dart';

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

  Future<String> get effectiveUrl async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return url;
    } else {
      if (title != null && title!.isNotEmpty) {
        return Uri.encodeFull('assets/images/$title.jpg');
      }
      return url;
    }
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    // The file URL is the only required field.
    if (map['file'] == null) {
      throw ArgumentError('Photo map must contain a "file" key');
    }

    return Photo(
      url: map['file'],
      title: map['titl']?.toString(),
      note: map['note'],
      date: map['_date'],
    );
  }
}