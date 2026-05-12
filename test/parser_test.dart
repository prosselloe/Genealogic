import 'package:flutter_test/flutter_test.dart';
import 'package:genealogic/gedcom_parser.dart';

void main() {
  test('Parser should process a simple record', () async {
    final parser = GedcomParser();
    const sampleGedcom = '''
0 @I1@ INDI
1 NAME John /Doe/
1 BIRT
2 DATE 1 JAN 1970
2 PLAC Someplace
1 DEAT
2 DATE 1 JAN 2024
2 PLAC Anotherplace
''';
    await parser.parse(sampleGedcom);
    expect(parser.individuals.length, 1);
    final person = parser.individuals['I1'];
    expect(person, isNotNull);
    expect(person!['name'], 'John Doe');
    final birth = person['birth'] as Map<String, dynamic>?;
    expect(birth, isNotNull);
    expect(birth!['date'], '1 JAN 1970');
    expect(birth['plac'], 'Someplace');
    final death = person['deat'] as Map<String, dynamic>?;
    expect(death, isNotNull);
    expect(death!['date'], '1 JAN 2024');
    expect(death['plac'], 'Anotherplace');
  });
}
