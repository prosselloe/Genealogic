import 'dart:convert';

class Photo {
  String url;
  final String? title;
  final String? format;
  final String? note;
  final List<double> position;
  final bool isPersonal;
  final String? photoRin;
  final String? parentRin;
  String? resolvedUrl;

  Photo({
    this.url = '',
    this.title,
    this.format,
    this.note,
    this.position = const [],
    this.isPersonal = false,
    this.photoRin,
    this.parentRin,
    this.resolvedUrl,
  });

  factory Photo.fromMap(Map<String, dynamic> map) {
    List<double> parsedPosition = [];
    final posValue = map['position'];

    if (posValue is String) {
      parsedPosition = posValue
          .split(' ')
          .where((s) => s.isNotEmpty)
          .map((s) => double.tryParse(s) ?? 0.0)
          .toList();
    } else if (posValue is List) {
      parsedPosition = posValue
          .map((e) => (e is num)
              ? e.toDouble()
              : double.tryParse(e.toString()) ?? 0.0)
          .toList();
    }

    return Photo(
      url: map['file'] as String? ?? '',
      title: map['titl'] as String?,
      format: map['form'] as String?,
      note: map['note'] as String?,
      position: parsedPosition,
      isPersonal: (map['personalphoto'] as String? ?? 'N') == 'Y',
      photoRin: map['photorin'] as String?,
      parentRin: map['parentrin'] as String?,
      resolvedUrl: map['resolvedUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'file': url,
      'titl': title,
      'form': format,
      'note': note,
      'position': position.map((p) => p.toString()).join(' '),
      'pers': isPersonal ? 'Y' : 'N',
      'photorin': photoRin,
      'parentrin': parentRin,
      'resolvedUrl': resolvedUrl,
    };
  }

  String toJson() => json.encode(toMap());

  factory Photo.fromJson(String source) => Photo.fromMap(json.decode(source));
}
