import 'dart:async';
import 'package:genealogic_balear/src/parser_utils.dart';

// Data Models
class _Person {
  final String id;
  String givenName, surname;
  String? sex;
  int? ageAtMarriage;
  String? birthDate, birthPlace, deathDate, deathPlace, notes, famcId, famsId; // Added deathPlace
  _Person({required this.id, this.givenName = '', this.surname = '', this.sex});
}

class _Family {
  final String id;
  String? husbandId, wifeId, marriageDate, marriagePlace;
  final List<String> childrenIds = [];
  _Family({required this.id});
}

class GedcomTransformer {
  Future<String> transform(String inputText) async {
    final lines = inputText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final people = <String, _Person>{};
    final families = <String, _Family>{};
    final lineageAncestors = <String, _Family>{}; // Map lineage name to its family
    int pCounter = 1, fCounter = 1;

    _Person? patriarch, matriarch;
    _Family? currentFamily;
    String? currentLineageName;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (line.startsWith('[') && line.endsWith(']')) continue; // Ignore commented out lines

      if (RegExp(r'^[A-ZÀ-Ú ]+$').hasMatch(line)) { // Lineage Name
        currentLineageName = line;
        if (!lineageAncestors.containsKey(currentLineageName)) {
          final ancestor = _Person(id: '@I${pCounter++}@', givenName: currentLineageName, sex: 'M');
          ancestor.birthPlace = 'Felanitx';
          people[ancestor.id] = ancestor;
          final ancestorFamily = _Family(id: '@F${fCounter++}@')..husbandId = ancestor.id;
          families[ancestorFamily.id] = ancestorFamily;
          lineageAncestors[currentLineageName] = ancestorFamily;
        }
      } else if (line.startsWith('*')) { // Marriage & Matriarch
        final marriageLine = line.substring(1).trim();
        final marriageParts = marriageLine.split('a ');
        final marriageDateStr = marriageParts.first;
        String? marriagePlace;
        if (marriageParts.length > 1) {
          marriagePlace = 'a ${marriageParts.sublist(1).join('a ').split(',').first.trim()}';
        }

        final dateMatch = RegExp(r'^[\d\s,-]+|(N)').firstMatch(marriageDateStr);

        var details = marriageLine.substring(dateMatch?.group(0)?.length ?? 0).trim();
        if (details.startsWith(',')) {
          details = details.substring(1).trim();
        }

        final testamentInfo = extractTestamentNotes(details);
        if (testamentInfo != null && patriarch != null) {
          patriarch.deathDate = 'BEF ${testamentInfo.date}';
          patriarch.deathPlace = 'Felanitx';
        }

        final nameAndParents = details.replaceAll(RegExp(r'\s*T\..*'), '').trim().replaceAll(RegExp(r'\.$'), '');
        final wifeParts = nameAndParents.split(',');
        final wifeFullName = wifeParts[0].replaceAll(RegExp(r'\s*\(.*?\)'), '').trim();
        final wifeNameParts = wifeFullName.split(' ');
        final wifeSurname = wifeNameParts.removeLast();
        final wifeGivenName = wifeNameParts.join(' ');

        matriarch = _Person(id: '@I${pCounter++}@', givenName: wifeGivenName, surname: wifeSurname, sex: 'F');
        matriarch.birthPlace = 'Felanitx';
        matriarch.ageAtMarriage = extractAge(details);
        matriarch.deathDate = extractDeathDate(details);
        if (matriarch.deathDate != null) matriarch.deathPlace = 'Felanitx';

        if (testamentInfo != null) {
          matriarch.notes = testamentInfo.rawText;
        }
        people[matriarch.id] = matriarch;
        
        if (currentFamily != null) {
          currentFamily.wifeId = matriarch.id;
          currentFamily.marriageDate = (parseDate(dateMatch?.group(0)?.replaceAll(' ', '')) ?? dateMatch?.group(0) ?? '');
          currentFamily.marriagePlace = marriagePlace ?? 'Felanitx';
          matriarch.famsId = currentFamily.id;
        }


        if (wifeParts.length > 1) {
          final matriarchOriginalSurname = matriarch.surname;
          final wifeParentInfo = extractParentage(wifeParts[1], wifeGivenName, matriarchOriginalSurname);
          if (wifeParentInfo != null) {
            final father = _Person(id: '@I${pCounter++}@', givenName: wifeParentInfo.fatherName, surname: matriarchOriginalSurname, sex: 'M');
            father.birthPlace = 'Felanitx';
            final mother = _Person(id: '@I${pCounter++}@', givenName: wifeParentInfo.motherName, surname: wifeParentInfo.motherSurname, sex: 'F');
            mother.birthPlace = 'Felanitx';
            people[father.id] = father;
            people[mother.id] = mother;

            final mFamily = _Family(id: '@F${fCounter++}@')
              ..husbandId = father.id
              ..wifeId = mother.id
              ..childrenIds.add(matriarch.id);
            father.famsId = mother.famsId = mFamily.id;
            matriarch.famcId = mFamily.id;
            families[mFamily.id] = mFamily;

            if (wifeParentInfo.motherSurname.isNotEmpty) {
                matriarch.surname = '${matriarch.surname} ${wifeParentInfo.motherSurname}';
            }
          }
        }
      } else if (line.startsWith('–') || line.startsWith('-')) { // Children
        final childLine = line.substring(1).trim();
        final childName = extractChildName(childLine);
        final patriarchFirstSurname = patriarch?.surname.split(' ').first ?? currentLineageName;
        final matriarchFirstSurname = matriarch?.surname.split(' ').first ?? '';
        final childSurname = '$patriarchFirstSurname $matriarchFirstSurname'.trim();

        final child = _Person(id: '@I${pCounter++}@', givenName: childName, surname: childSurname);
        child.birthPlace = 'Felanitx';

        child.sex = inferSex(child.givenName);
        child.birthDate = extractDate(childLine);
        child.deathDate = extractDeathDate(childLine);
        if (child.deathDate != null) child.deathPlace = 'Felanitx';

        child.notes = extractChildNotes(childLine, childName);

        child.famcId = currentFamily?.id;

        people[child.id] = child;
        if (currentFamily != null) {
            currentFamily.childrenIds.add(child.id);
        }
      } else if (line.contains(',') && i + 1 < lines.length) { // Patriarch
        final nameParts = line.split(',');
        patriarch = _Person(id: '@I${pCounter++}@', surname: nameParts[0].trim(), givenName: nameParts[1].trim());
        patriarch.birthPlace = 'Felanitx';
        patriarch.sex = inferSex(patriarch.givenName);
        patriarch.deathDate = extractDeathDate(line);
        if (patriarch.deathDate != null) patriarch.deathPlace = 'Felanitx';
        
        final notesMatch = RegExp(r',\s*([a-zç]+)$|\(([^)]+)\)$').firstMatch(line);
        if (notesMatch != null) {
            patriarch.notes = (patriarch.notes ?? '') + (notesMatch.group(1) ?? notesMatch.group(2) ?? '').trim();
        }
        
        people[patriarch.id] = patriarch;

        _Person? patriarchFather;

        final nextLine = lines[i + 1].trim();
        if (nextLine.startsWith('de')) {
            i++; 
            line = lines[i];
            patriarch.ageAtMarriage = extractAge(line);

            final testamentInfo = extractTestamentNotes(line);
            if (testamentInfo != null) {
                final notes = testamentInfo.rawText.replaceAll(RegExp(r'\s*T\.\s*'), '');
                patriarch.notes = (patriarch.notes ?? '') + notes;
                patriarch.deathDate = 'BEF ${testamentInfo.date}';
                patriarch.deathPlace = 'Felanitx';
            }

            var parentLine = line;
            if (testamentInfo != null) {
                final testamentIndex = parentLine.indexOf(testamentInfo.rawText);
                if (testamentIndex != -1) {
                    parentLine = parentLine.substring(0, testamentIndex).trim();
                }
            }
            final plusIndex = parentLine.indexOf('+');
            if (plusIndex != -1) {
                patriarch.deathDate ??= extractDeathDate(parentLine);
                if (patriarch.deathDate != null) patriarch.deathPlace ??= 'Felanitx';
            }
            parentLine = parentLine.replaceAll(RegExp(r'\.$'), '').trim();

            final patriarchOriginalSurname = patriarch.surname;
            final parentInfo = extractParentage(parentLine, patriarch.givenName, patriarchOriginalSurname);
            if (parentInfo != null) {
                final father = _Person(id: '@I${pCounter++}@', givenName: parentInfo.fatherName, surname: patriarchOriginalSurname, sex: 'M');
                father.birthPlace = 'Felanitx';
                patriarchFather = father;
                final mother = _Person(id: '@I${pCounter++}@', givenName: parentInfo.motherName, surname: parentInfo.motherSurname, sex: 'F');
                mother.birthPlace = 'Felanitx';
                people[father.id] = father;
                people[mother.id] = mother;

                final pFamily = _Family(id: '@F${fCounter++}@')
                    ..husbandId = father.id
                    ..wifeId = mother.id
                    ..childrenIds.add(patriarch.id);
                father.famsId = mother.famsId = pFamily.id;
                patriarch.famcId = pFamily.id;
                families[pFamily.id] = pFamily;

                if (parentInfo.motherSurname.isNotEmpty) {
                    patriarch.surname = '${patriarch.surname} ${parentInfo.motherSurname}';
                }
            }
        }

        if (currentLineageName != null && lineageAncestors.containsKey(currentLineageName)) {
            final ancestorFamily = lineageAncestors[currentLineageName]!;
            final personToLink = patriarchFather ?? patriarch;

            if (!ancestorFamily.childrenIds.contains(personToLink.id)) {
                ancestorFamily.childrenIds.add(personToLink.id);
                personToLink.famcId = ancestorFamily.id;
            }
        }

        currentFamily = _Family(id: '@F${fCounter++}@')..husbandId = patriarch.id;
        patriarch.famsId = currentFamily.id;
        families[currentFamily.id] = currentFamily;
      }
    }
    return _generateGedcom(people, families);
  }


  String _generateGedcom(Map<String, _Person> people, Map<String, _Family> families) {
    final buffer = StringBuffer()..writeln('0 HEAD')..writeln('1 SOUR GenealogicBalear')..writeln('1 CHAR UTF-8');
    final sortedPeople = people.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    final sortedFamilies = families.values.toList()..sort((a, b) => a.id.compareTo(b.id));

    for (final p in sortedPeople) {
      buffer.writeln('0 ${p.id} INDI');
      buffer.writeln('1 NAME ${p.givenName} /${p.surname}/');
      if (p.sex != null) {
        buffer.writeln('1 SEX ${p.sex}');
      }

      String? finalBirthDate = p.birthDate;
      if (p.ageAtMarriage != null && p.famsId != null && p.birthDate == null) {
        final family = families[p.famsId];
        if (family?.marriageDate != null) {
          final year = _getYearFromDate(family!.marriageDate!);
          if (year != null) {
              final birthYear = year - p.ageAtMarriage!;
              finalBirthDate = 'BEF $birthYear';
          }
        }
      }

      if (finalBirthDate != null || p.birthPlace != null) {
        buffer.writeln('1 BIRT');
        if (finalBirthDate != null) {
            buffer.writeln('2 DATE $finalBirthDate');
        }
        if (p.birthPlace != null) {
            buffer.writeln('2 PLAC ${p.birthPlace}');
        }
      }

      if (p.deathDate != null) {
        buffer.writeln('1 DEAT');
        buffer.writeln('2 DATE ${p.deathDate}');
        if (p.deathPlace != null) {
            buffer.writeln('2 PLAC ${p.deathPlace}');
        }
      }

      if (p.notes != null && p.notes!.trim().isNotEmpty) {
          p.notes!.trim().split('\n').forEach((note) {
              buffer.writeln('1 NOTE $note');
          });
      }
      if (p.famcId != null) {
        buffer.writeln('1 FAMC ${p.famcId}');
      }
      if (p.famsId != null) {
        buffer.writeln('1 FAMS ${p.famsId}');
      }
    }
    for (final f in sortedFamilies) {
      buffer.writeln('0 ${f.id} FAM');
      if (f.husbandId != null) {
        buffer.writeln('1 HUSB ${f.husbandId}');
      }
      if (f.wifeId != null) {
        buffer.writeln('1 WIFE ${f.wifeId}');
      }

      if (f.marriageDate != null && f.marriageDate!.trim().isNotEmpty || f.marriagePlace != null) {
          buffer.writeln('1 MARR');
          if (f.marriageDate != null && f.marriageDate!.trim().isNotEmpty) {
              buffer.writeln('2 DATE ${f.marriageDate}');
          }
          if (f.marriagePlace != null) {
              buffer.writeln('2 PLAC ${f.marriagePlace}');
          }
      }
      
      final sortedChildren = f.childrenIds..sort();
      for (final c in sortedChildren) {
        buffer.writeln('1 CHIL $c');
      }
    }
    buffer.writeln('0 TRLR');
    return buffer.toString();
  }

  int? _getYearFromDate(String date) {
      final yearRegex = RegExp(r'(\d{4})');
      final match = yearRegex.firstMatch(date);
      if (match != null) {
          return int.tryParse(match.group(1)!);
      }
      return null;
  }
}
