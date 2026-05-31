import 'photo.dart';

class Person {
  final String id;
  final String name;
  final String? surn;
  final String? sex;
  final String? birthDate;
  final String? birthPlace;
  final String? deathDate;
  final String? deathPlace;
  final String? age;
  final List<Photo> photos;
  final List<String> sources;
  final List<String> notes;
  final String? famc; // Family as Child
  final List<String> fams; // Family as Spouse

  Person({
    required this.id,
    required this.name,
    this.surn,
    this.sex,
    this.birthDate,
    this.birthPlace,
    this.deathDate,
    this.deathPlace,
    this.age,
    this.photos = const [],
    this.sources = const [],
    this.notes = const [],
    this.famc,
    this.fams = const [],
  });

  String get surname {
    if (surn != null && surn!.isNotEmpty) {
      return surn!;
    }
    final nameParts = name.split('/');
    if (nameParts.length > 1) {
      final potentialSurname = nameParts[1].trim();
      if (potentialSurname.isNotEmpty) {
        return potentialSurname;
      }
    }
    final words = name.split(' ');
    if (words.length > 1) {
      return words.last;
    }
    return '';
  }

 factory Person.fromMap(Map<String, dynamic> map) {
    final birthMap = map['birt'] as Map<String, dynamic>?;
    final deathMap = map['deat'] as Map<String, dynamic>?;

    final photosList = (map['photos'] as List?)
        ?.map((photoData) => Photo.fromMap(photoData as Map<String, dynamic>))
        .toList() ??
        [];

    final sourcesList =
        (map['sour'] as List?)?.map((source) => source.toString()).toList() ?? [];

    final notesList =
        (map['notes'] as List?)?.map((note) => note.toString()).toList() ?? [];

    final famsList =
        (map['fams'] as List?)?.map((fam) => fam.toString()).toList() ?? [];

    return Person(
      id: map['id'] as String? ?? 'Unknown ID',
      name: map['name'] as String? ?? 'Unknown Name',
      surn: map['surn'] as String?,
      sex: map['sex'] as String?,
      birthDate: birthMap?['date'] as String? ?? birthMap?['_date'] as String?,
      birthPlace: birthMap?['plac'] as String? ?? birthMap?['_place'] as String?,
      deathDate: deathMap?['date'] as String? ?? deathMap?['_date'] as String?,
      deathPlace: deathMap?['plac'] as String? ?? deathMap?['_place'] as String?,
      age: deathMap?['age'] as String?,
      photos: photosList,
      sources: sourcesList,
      notes: notesList,
      famc: map['famc'] as String?,
      fams: famsList,
    );
  }
}
