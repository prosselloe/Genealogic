import 'package:genealogic/models/person.dart';

class Family {
  final String id;
  final Person? husband;
  final Person? wife;
  final List<Person> children;

  Family({
    required this.id,
    this.husband,
    this.wife,
    this.children = const [],
  });
}
