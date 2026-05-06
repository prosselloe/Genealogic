import 'dart:developer' as developer;

class GedcomParser {
  final Map<String, Map<String, dynamic>> individuals = {};
  final List<Map<String, dynamic>> families = [];

  Future<void> parse(String gedcomData) async {
    developer.log('Starting GEDCOM parsing...', name: 'GedcomParser.parse');

    final lines = gedcomData.split('\n');
    final processedLines = <String>[];

    for (int i = 0; i < lines.length; i++) {
        var currentLine = lines[i].trim();
        if (currentLine.isEmpty) continue;

        while (i + 1 < lines.length) {
            final nextLine = lines[i + 1].trim();
            final parts = nextLine.split(' ');
            if (parts.length > 1) {
                if (parts[1] == 'CONC') {
                    // Corrected to use interpolation
                    currentLine += ' ${parts.sublist(2).join(' ')}';
                    i++; 
                } else if (parts[1] == 'CONT') {
                    // Corrected to use interpolation
                    currentLine += '\n${parts.sublist(2).join(' ')}';
                    i++;
                } else {
                    break;
                }
            } else {
                break;
            }
        }
        processedLines.add(currentLine);
    }

    Map<String, dynamic>? currentRecord;
    String? lastTag;

    for (var line in processedLines) {
      final parts = line.split(' ');
      if (parts.length < 2) continue;

      final level = int.tryParse(parts[0]);
      if (level == null) continue;

      final tagOrId = parts[1];

      if (level == 0) {
        if (currentRecord != null) {
          if (currentRecord.containsKey('isFamily')) {
            families.add(currentRecord..remove('isFamily'));
          } else {
            individuals[currentRecord['id']] = currentRecord;
          }
        }

        if (parts.length > 2 && (parts[2] == 'INDI' || parts[2] == 'FAM')) {
            final type = parts[2];
            final id = tagOrId;
            currentRecord = {'id': id};
            if (type == 'FAM') {
                currentRecord['isFamily'] = true;
            }
        } else {
            currentRecord = null;
        }
      } else if (currentRecord != null) {
          final tag = tagOrId;
          final value = parts.sublist(2).join(' ');
          
          if (level == 1) {
              lastTag = tag;
              if (tag == 'HUSB' || tag == 'WIFE' || tag == 'CHIL') {
                  if (!currentRecord.containsKey(tag.toLowerCase())) {
                      currentRecord[tag.toLowerCase()] = value;
                  } else {
                      if (currentRecord[tag.toLowerCase()] is List) {
                          currentRecord[tag.toLowerCase()].add(value);
                      } else {
                          currentRecord[tag.toLowerCase()] = [currentRecord[tag.toLowerCase()], value];
                      }
                  }
              } else if (tag == 'BIRT' || tag == 'DEAT') {
                  currentRecord[tag] = {};
              } else {
                  currentRecord[tag.toLowerCase()] = value.replaceAll('/', '');
              }
          } else if (level == 2 && lastTag != null) {
              if (currentRecord.containsKey(lastTag) && currentRecord[lastTag] is Map) {
                  (currentRecord[lastTag] as Map)[tag.toLowerCase()] = value;
              }
              if (lastTag == 'OBJE' && tag == 'FILE' && Uri.tryParse(value)?.isAbsolute == true) {
                  currentRecord['photo'] = value;
              }
          }
      }
    }

    if (currentRecord != null) {
      if (currentRecord.containsKey('isFamily')) {
        families.add(currentRecord..remove('isFamily'));
      } else {
        individuals[currentRecord['id']] = currentRecord;
      }
    }

    developer.log('Finished parsing. Found ${individuals.length} individuals and ${families.length} families.', name: 'GedcomParser.parse');
  }
}
