import 'package:flutter_test/flutter_test.dart';
import 'package:genealogic_balear/gedcom_transformer.dart';

void main() {
  group('GedcomTransformer', () {
    test('Should correctly calculate full birth dates from marriage info', () async {
      final transformer = GedcomTransformer();
      const inputText = '''
ABRAHAM

Abraham, Francesc
de Guillem i de Caterina Adrover (29)
* 17-12-1656 Margarita Puig, de Joan i de Coloma Binimelis (20). T. 13-10- 1697, vda (O-280)

''';

      final result = await transformer.transform(inputText);

      // Patriarch should have a calculated birth date: BEF 17 DEC 1627
      final patriarchBirthRegex = RegExp(r'0 @I3@ INDI(?:.|\n)*?1 BIRT\s+2 DATE BEF 17 DEC 1627');
      expect(result, contains(patriarchBirthRegex), reason: 'Patriarch birth date is missing or incorrect.');

      // Matriarch should have a calculated birth date: BEF 17 DEC 1636
      final matriarchBirthRegex = RegExp(r'0 @I4@ INDI(?:.|\n)*?1 BIRT\s+2 DATE BEF 17 DEC 1636');
      expect(result, contains(matriarchBirthRegex), reason: 'Matriarch birth date is missing or incorrect.');

      // Check for marriage date
      final marriageRegex = RegExp(r'1 MARR\s+2 DATE 17 DEC 1656');
      expect(result, contains(marriageRegex), reason: 'Marriage date is missing or incorrect.');
    });
  });
}
