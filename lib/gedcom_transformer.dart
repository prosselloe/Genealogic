import 'dart:async';

class Individual {
  String id;
  String? firstName;
  String? surname;
  String? sex; // M, F, or U
  String? birthDate;
  String? parentFamilyId;
  List<String> spouseFamilyIds = [];
  List<String> notes = [];

  Individual({ required this.id, this.sex });

  String get fullName => [firstName, surname].where((n) => n != null && n.isNotEmpty).join(' ');
  String get gedcomName => '${firstName ?? ''} /${surname ?? ''}/'.trim();
}

class Family {
  String id;
  String? husbandId;
  String? wifeId;
  String? marriageDate;
  List<String> childrenIds = [];

  Family({ required this.id });
}

class GedcomTransformer {
  final List<Individual> _individuals = [];
  final List<Family> _families = [];
  int _individualCounter = 0;
  int _familyCounter = 0;

  Future<String> transform(String text) async {
    _reset();
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    if (lines.isEmpty) return _generateGedcom();

    final lineageName = lines.first;
    final ancestor = _createIndividual(surname: lineageName, sex: 'M');

    String? marriageDateStr;
    int? patriarchAge;
    int patriarchLineIndex = -1;

    // Find marriage info first to get the date
    final marriageLine = lines.firstWhere((line) => line.startsWith('*'), orElse: () => '');
    final marriageRegex = RegExp(r'\* (.*?), (.*?), de (.*) i de (.*) \((\d+)\)');
    final marriageMatch = marriageRegex.firstMatch(marriageLine);

    if (marriageMatch != null) {
      marriageDateStr = marriageMatch.group(1)!.trim();
    }

    // Find patriarch block
    patriarchLineIndex = lines.indexWhere((line) => !line.startsWith('*') && lines.indexOf(line) > 0 && line.contains(','));
    if (patriarchLineIndex == -1) return _generateGedcom();

    final patriarchNameLine = lines[patriarchLineIndex];
    final patriarchParentsLine = lines[patriarchLineIndex + 1];
    
    final ageRegex = RegExp(r'\((\d+)\)');
    final patriarchAgeMatch = ageRegex.firstMatch(patriarchParentsLine);
    if (patriarchAgeMatch != null) {
      patriarchAge = int.tryParse(patriarchAgeMatch.group(1)!);
    }

    final patriarch = _processPatriarchBlock(patriarchNameLine, patriarchParentsLine, ancestor, marriageDateStr, patriarchAge);

    if (marriageMatch != null) {
      _processMarriageBlock(marriageMatch, patriarch, marriageDateStr!);
    }

    return _generateGedcom();
  }

  Individual _processPatriarchBlock(String nameLine, String parentsLine, Individual ancestor, String? marriageDate, int? age) {
      final nameParts = nameLine.split(',');
      final surname = nameParts[0].trim();
      final firstName = nameParts.length > 1 ? nameParts[1].trim() : '';

      final parentsRegex = RegExp(r'de (.*) i de (.*) \(.*\)');
      final parentsMatch = parentsRegex.firstMatch(parentsLine);

      Individual? father;
      Individual? mother;

      if (parentsMatch != null) {
          final fatherFirstName = parentsMatch.group(1)!.trim();
          father = _createIndividual(firstName: fatherFirstName, surname: surname, sex: 'M');
          
          final ancestorFamily = _createFamily(husband: ancestor);
          _linkChildToFamily(child: father, family: ancestorFamily);

          final motherFullName = parentsMatch.group(2)!.trim();
          final motherNameParts = motherFullName.split(' ');
          final motherSurname = motherNameParts.last;
          final motherFirstName = motherNameParts.sublist(0, motherNameParts.length - 1).join(' ');
          mother = _createIndividual(firstName: motherFirstName, surname: motherSurname, sex: 'F');
      }

      final patriarch = _createIndividual(firstName: firstName, surname: '$surname ${mother?.surname ?? ''}'.trim(), sex: 'M');
      if (marriageDate != null && age != null) {
          patriarch.birthDate = _calculateBirthDate(marriageDate, age);
      }
      
      if (father != null && mother != null) {
          final parentsFamily = _createFamily(husband: father, wife: mother);
          _linkChildToFamily(child: patriarch, family: parentsFamily);
      }
      return patriarch;
  }

  void _processMarriageBlock(Match marriageMatch, Individual patriarch, String marriageDateStr) {
    final wifeName = marriageMatch.group(2)!.trim();
    final wifeFatherName = marriageMatch.group(3)!.trim();
    final wifeMotherFullName = marriageMatch.group(4)!.trim();
    final wifeAge = int.tryParse(marriageMatch.group(5)!) ?? 0;

    final wifeNameParts = wifeName.split(' ');
    final wifeSurname = wifeNameParts.last;
    final wifeFirstName = wifeNameParts.sublist(0, wifeNameParts.length-1).join(' ');

    final wifeMotherNameParts = wifeMotherFullName.split(' ');
    final wifeMotherSurname = wifeMotherNameParts.last;
    final wifeMotherFirstName = wifeMotherNameParts.sublist(0, wifeMotherNameParts.length - 1).join(' ');

    final matriarch = _createIndividual(
      firstName: wifeFirstName,
      surname: '$wifeSurname $wifeMotherSurname'.trim(),
      sex: 'F',
    );
    matriarch.birthDate = _calculateBirthDate(marriageDateStr, wifeAge);
    
    final matriarchFather = _createIndividual(firstName: wifeFatherName, surname: wifeSurname, sex: 'M');
    final matriarchMother = _createIndividual(firstName: wifeMotherFirstName, surname: wifeMotherSurname, sex: 'F');
    
    final matriarchParentsFamily = _createFamily(husband: matriarchFather, wife: matriarchMother);
    _linkChildToFamily(child: matriarch, family: matriarchParentsFamily);

    final marriageFamily = _createFamily(husband: patriarch, wife: matriarch);
    marriageFamily.marriageDate = _formatDate(marriageDateStr);
  }

  String _calculateBirthDate(String marriageDateStr, int age) {
    final dateParts = marriageDateStr.replaceAll(',', '-').split('-');
    if (dateParts.length != 3) return '';

    String day, month, yearStr;
     if (dateParts[0].length == 4) { // Y-M-D
        yearStr = dateParts[0];
        month = dateParts[1];
        day = dateParts[2];
    } else { // D-M-Y
        day = dateParts[0];
        month = dateParts[1];
        yearStr = dateParts[2];
    }

    final marriageYear = int.parse(yearStr);
    final birthYear = marriageYear - age;
    final monthAbbr = _getGedcomMonth(month);

    return 'BEF $day $monthAbbr $birthYear'.toUpperCase();
  }

  String _formatDate(String dateStr) {
    final dateParts = dateStr.replaceAll(',', '-').split('-');
    if (dateParts.length != 3) return dateStr;

    String day, month, year;
    if (dateParts[0].length == 4) { // Y-M-D
      year = dateParts[0];
      month = dateParts[1];
      day = dateParts[2];
    } else { // D-M-Y
      day = dateParts[0];
      month = dateParts[1];
      year = dateParts[2];
    }

    final monthAbbr = _getGedcomMonth(month);
    return '$day $monthAbbr $year'.toUpperCase();
  }

  String _getGedcomMonth(String month) {
    const months = {
      '1': 'JAN', '2': 'FEB', '3': 'MAR', '4': 'APR', '5': 'MAY', '6': 'JUN',
      '7': 'JUL', '8': 'AUG', '9': 'SEP', '10': 'OCT', '11': 'NOV', '12': 'DEC'
    };
    return months[month.trim()] ?? month;
  }

  void _reset() {
    _individuals.clear();
    _families.clear();
    _individualCounter = 0;
    _familyCounter = 0;
  }

  Individual _createIndividual({String? firstName, String? surname, String sex = 'U'}) {
    final ind = Individual(id: '@I${_individualCounter++}@', sex: sex)
      ..firstName = firstName
      ..surname = surname;
    _individuals.add(ind);
    return ind;
  }

  Family _createFamily({Individual? husband, Individual? wife}) {
    final fam = Family(id: '@F${_familyCounter++}@')
      ..husbandId = husband?.id
      ..wifeId = wife?.id;
    husband?.spouseFamilyIds.add(fam.id);
    wife?.spouseFamilyIds.add(fam.id);
    _families.add(fam);
    return fam;
  }

  void _linkChildToFamily({required Individual child, required Family family}) {
    child.parentFamilyId = family.id;
    family.childrenIds.add(child.id);
  }

  String _generateGedcom() {
    final buffer = StringBuffer();

    buffer.writeln('0 HEAD');
    buffer.writeln('1 SOUR Genealogic_Balear');
    buffer.writeln('1 GEDC');
    buffer.writeln('2 VERS 5.5.1');
    buffer.writeln('2 FORM LINEAGE-LINKED');
    buffer.writeln('1 CHAR UTF-8');
    buffer.writeln('1 LANG Catalan');

    for (final individual in _individuals) {
      buffer.writeln('0 ${individual.id} INDI');
      buffer.writeln('1 NAME ${individual.gedcomName}');
      if (individual.sex != 'U') {
        buffer.writeln('1 SEX ${individual.sex}');
      }
      if (individual.birthDate != null && individual.birthDate!.isNotEmpty) {
        buffer.writeln('1 BIRT');
        buffer.writeln('2 DATE ${individual.birthDate}');
      }
      if (individual.parentFamilyId != null) {
        buffer.writeln('1 FAMC ${individual.parentFamilyId}');
      }
      for (final famsId in individual.spouseFamilyIds) {
        buffer.writeln('1 FAMS $famsId');
      }
    }

    for (final family in _families) {
      buffer.writeln('0 ${family.id} FAM');
      if (family.husbandId != null) {
        buffer.writeln('1 HUSB ${family.husbandId}');
      }
      if (family.wifeId != null) {
        buffer.writeln('1 WIFE ${family.wifeId}');
      }
      if (family.childrenIds.isNotEmpty) {
        for (final childId in family.childrenIds) {
          buffer.writeln('1 CHIL $childId');
        }
      }
      if (family.marriageDate != null) {
        buffer.writeln('1 MARR');
        buffer.writeln('2 DATE ${family.marriageDate}');
      }
    }

    buffer.writeln('0 TRLR');

    return buffer.toString();
  }
}
