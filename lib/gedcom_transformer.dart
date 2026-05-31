import 'dart:async';
import 'package:genealogic_balear/src/transformer_utils.dart';

// Internal Data Models
class _Person {
  String id;
  String givenName, surname, birthPlace = 'Felanitx';
  String? sex, secondarySurname, birthDate, deathDate, deathPlace, notes, famcId, famsId;
  int? ageAtMarriage;

  _Person({required this.id, this.givenName = '', this.surname = '', this.sex});

  String get fullName => '$givenName $surname ${secondarySurname ?? ''}'.trim();
}

class _Family {
  String id;
  String? husbandId, wifeId, marriageDate, marriagePlace;
  final List<String> childrenIds = [];
  _Family({required this.id});
}

class GedcomTransformer {
  int _pCounter = 1;
  int _fCounter = 1;
  final Map<String, _Person> _people = {};
  final Map<String, _Family> _families = {};
  final Map<String, _Person> _lineageAncestors = {};

  Future<String> transform(String inputText) async {
    // Reset state for each transformation
    _pCounter = 1;
    _fCounter = 1;
    _people.clear();
    _families.clear();
    _lineageAncestors.clear();

    final familyBlocks = inputText.split(RegExp(r'\n\s*\n')); // Split by blank lines

    for (final block in familyBlocks) {
      if (block.trim().isNotEmpty) {
        await _parseFamilyBlock(block.trim());
      }
    }

    return _generateGedcom();
  }

  Future<void> _parseFamilyBlock(String block) async {
    final lines = block.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return;

    // First line could be lineage or patriarch
    String currentLineageName = '';
    int lineIndex = 0;

    if (RegExp(r'^[A-ZÀ-Ú ]+$').hasMatch(lines[lineIndex])) {
      currentLineageName = lines[lineIndex];
      if (!_lineageAncestors.containsKey(currentLineageName)) {
        final ancestor = _createPerson(givenName: currentLineageName, surname: '', sex: 'M');
        _lineageAncestors[currentLineageName] = ancestor;
      }
      lineIndex++;
    }

    // Process Patriarch
    String patriarchBlock = '';
    while (lineIndex < lines.length && !lines[lineIndex].startsWith('*') && !lines[lineIndex].startsWith('-')) {
      patriarchBlock += '${lines[lineIndex]}\n';
      lineIndex++;
    }
    
    final (patriarchName, patriarchSurname) = extractPatriarchName(patriarchBlock);
     if (patriarchName.isEmpty && patriarchSurname.isEmpty) return;

    final patriarch = _createPerson(givenName: patriarchName, surname: patriarchSurname, sex: 'M');
    patriarch.ageAtMarriage = extractAge(patriarchBlock);
    patriarch.deathDate = extractDeathDate(patriarchBlock);
    final notes = extractAllNotes(patriarchBlock);
    if (notes.isNotEmpty) patriarch.notes = notes;

    final parentInfo = extractParentInfo(patriarchBlock);
    _Person? patriarchFather;
    if (parentInfo != null) {
        patriarch.secondarySurname = parentInfo.motherSurname;
        final father = _createPerson(givenName: parentInfo.fatherName, surname: patriarch.surname, sex: 'M');
        final mother = _createPerson(givenName: parentInfo.motherName, surname: parentInfo.motherSurname, sex: 'F');
        _createFamily(husband: father, wife: mother, children: [patriarch]);
        patriarchFather = father;
    }

    if (currentLineageName.isNotEmpty && _lineageAncestors.containsKey(currentLineageName)) {
      final ancestor = _lineageAncestors[currentLineageName]!;
      final personToLink = patriarchFather ?? patriarch;
      
      final ancestorFamily = _families.values.firstWhere((f) => f.husbandId == ancestor.id, orElse: () {
          final newFamily = _createFamily(husband: ancestor);
          return newFamily;
      });

      if (!ancestorFamily.childrenIds.contains(personToLink.id)) {
          ancestorFamily.childrenIds.add(personToLink.id);
          personToLink.famcId = ancestorFamily.id;
      }
    }

    // Process Marriages and Children
    _Family? currentFamily;
    while(lineIndex < lines.length) {
        final line = lines[lineIndex];
        if (line.startsWith('*')) {
            currentFamily = _createFamily(husband: patriarch);
            final matriarch = _processMatriarchLine(line, currentFamily);
            patriarch.famsId = currentFamily.id;
            matriarch.famsId = currentFamily.id;
            lineIndex++;
        }
        else if (line.startsWith('-') && currentFamily != null) {
            _processChildLine(line, patriarch, _people[currentFamily.wifeId]!, currentFamily);
            lineIndex++;
        } else {
            lineIndex++; // Skip lines not conforming to the pattern
        }
    }
  }

  _Person _processMatriarchLine(String line, _Family family) {
      final marriageData = line.substring(1).trim();
      final date = extractDate(marriageData);
      family.marriageDate = date;
      family.marriagePlace = marriageData.contains('a Sta. Creu') ? 'Sta. Creu, Mallorca' : 'Felanitx';

      final nameInfoText = marriageData.replaceAll(RegExp(r'^[\d\s,-]+\s*|(N)\s*'), '').trim();
      final nameInfo = extractNameInfo(nameInfoText.split(',')[0]);

      final matriarch = _createPerson(givenName: nameInfo.givenName, surname: nameInfo.surname, sex: 'F');
      matriarch.ageAtMarriage = extractAge(marriageData);
      matriarch.deathDate = extractDeathDate(marriageData);
      final notes = extractAllNotes(marriageData);
      if(notes.isNotEmpty) matriarch.notes = notes;
      
      final testamentInfo = extractTestamentInfo(marriageData);
      if (testamentInfo != null) {
          matriarch.notes = '${matriarch.notes ?? ''}\n${testamentInfo.rawText}';
          // If matriarch is a widow, patriarch died before that date
          if (testamentInfo.rawText.contains('vda')) {
              final patriarch = _people[family.husbandId];
              patriarch?.deathDate = 'BEF ${testamentInfo.date}';
          }
      }
      
      final parentInfo = extractParentInfo(marriageData);
      if (parentInfo != null) {
          matriarch.secondarySurname = parentInfo.motherSurname;
          final father = _createPerson(givenName: parentInfo.fatherName, surname: matriarch.surname, sex: 'M');
          final mother = _createPerson(givenName: parentInfo.motherName, surname: parentInfo.motherSurname, sex: 'F');
          _createFamily(husband: father, wife: mother, children: [matriarch]);
      }
      family.wifeId = matriarch.id;
      return matriarch;
  }

  void _processChildLine(String line, _Person father, _Person mother, _Family family) {
      final childLine = line.substring(1).trim();
      final nameEndIndex = childLine.contains('(') ? childLine.indexOf('(') : childLine.length;
      final childName = childLine.substring(0, nameEndIndex).trim();

      final child = _createPerson(givenName: childName, surname: father.surname, sex: inferSex(childName));
      child.secondarySurname = mother.surname;
      child.birthDate = extractDate(childLine);
      child.deathDate = extractDeathDate(childLine);
      final notes = extractAllNotes(childLine);
       if(notes.isNotEmpty) child.notes = notes;

      child.famcId = family.id;
      family.childrenIds.add(child.id);
  }

  // --- Helper Methods to create and add data ---

  _Person _createPerson({String givenName = '', String surname = '', String? sex}) {
    final person = _Person(id: '@I${_pCounter++}@', givenName: givenName, surname: surname, sex: sex);
    _people[person.id] = person;
    return person;
  }

  _Family _createFamily({_Person? husband, _Person? wife, List<_Person>? children}) {
    final family = _Family(id: '@F${_fCounter++}@');
    if (husband != null) family.husbandId = husband.id;
    if (wife != null) family.wifeId = wife.id;
    if (children != null) {
      for (final child in children) {
        family.childrenIds.add(child.id);
        child.famcId = family.id;
      }
    }
    _families[family.id] = family;
    return family;
  }

  // --- GEDCOM Generation ---

  String _generateGedcom() {
    final buffer = StringBuffer();
    buffer.writeln('0 HEAD');
    buffer.writeln('1 SOUR GenealogicBalear');
    buffer.writeln('1 CHAR UTF-8');

    final sortedPeople = _people.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    for (final p in sortedPeople) {
      buffer.writeln('0 ${p.id} INDI');
      buffer.writeln('1 NAME ${p.givenName} /${p.surname}${p.secondarySurname != null ? ' ${p.secondarySurname!}' : ''}/');
      if (p.sex != null) buffer.writeln('1 SEX ${p.sex}');
      
      buffer.writeln('1 BIRT');
      if(p.birthDate != null) {
         buffer.writeln('2 DATE ${p.birthDate}');
      } else if (p.ageAtMarriage != null && p.famsId != null) {
          final family = _families[p.famsId!];
          if (family != null && family.marriageDate != null && !family.marriageDate!.contains('unknown')) {
            final marriageDate = family.marriageDate!;
              try {
                  final marriageYear = int.parse(marriageDate.split(' ').last);
                  final birthYear = marriageYear - p.ageAtMarriage!;
                  buffer.writeln('2 DATE BEF $birthYear');
              } catch (e) { /* silent */ }
          }
      }
      buffer.writeln('2 PLAC ${p.birthPlace}');

      if (p.deathDate != null) {
        buffer.writeln('1 DEAT');
        buffer.writeln('2 DATE ${p.deathDate}');
        if (p.deathPlace != null) buffer.writeln('2 PLAC ${p.deathPlace}');
      }

      if (p.notes != null && p.notes!.trim().isNotEmpty) {
        buffer.writeln('1 NOTE ${p.notes!.trim()}');
      }
      if (p.famcId != null) buffer.writeln('1 FAMC ${p.famcId}');
      if (p.famsId != null) buffer.writeln('1 FAMS ${p.famsId}');
    }

    final sortedFamilies = _families.values.toList()..sort((a,b) => a.id.compareTo(b.id));
    for (final f in sortedFamilies) {
      buffer.writeln('0 ${f.id} FAM');
      if (f.husbandId != null) buffer.writeln('1 HUSB ${f.husbandId}');
      if (f.wifeId != null) buffer.writeln('1 WIFE ${f.wifeId}');
      if (f.marriageDate != null || f.marriagePlace != null) {
        buffer.writeln('1 MARR');
        if (f.marriageDate != null && !f.marriageDate!.contains('unknown')) buffer.writeln('2 DATE ${f.marriageDate}');
        if (f.marriagePlace != null) buffer.writeln('2 PLAC ${f.marriagePlace}');
      }
      f.childrenIds.sort();
      for (final c in f.childrenIds) {
        buffer.writeln('1 CHIL $c');
      }
    }

    buffer.writeln('0 TRLR');
    return buffer.toString();
  }
}
