class Person {
  final String id;
  final String name;
  final String? birthDate;
  final String? deathDate;

  Person({
    required this.id,
    required this.name,
    this.birthDate,
    this.deathDate,
  });
}
