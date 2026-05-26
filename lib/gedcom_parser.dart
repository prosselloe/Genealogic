import 'dart:async';
import 'package:flutter/foundation.dart';

class GedcomParser {
  final Map<String, Map<String, dynamic>> individuals = {};
  final List<Map<String, dynamic>> families = [];
  final Set<String> uniquePlaces = <String>{};

  Future<void> parse(String gedcomData) async {
    if (kDebugMode) {
      print('Starting GEDCOM parsing...');
    }

    final lines = gedcomData.split('\n');
    Map<String, dynamic>? currentRecord;
    Map<String, dynamic>? currentEvent;
    
    for (int i = 0; i < lines.length; i++) {
        var line = lines[i].trim();
        if (line.isEmpty) continue;

        final parts = line.split(' ');
        final level = int.tryParse(parts[0]);
        if (level == null) continue;

        final tag = parts.length > 1 ? parts[1] : '';
        
        String value = '';
        if (parts.length > 2) {
            int valueStartIndex = line.indexOf(tag) + tag.length + 1;
            if (valueStartIndex < line.length) {
                value = line.substring(valueStartIndex);
            }
        }

        if (level == 0) {
            if (currentRecord != null) _saveRecord(currentRecord);
            currentRecord = null;
            currentEvent = null;
            if (tag.startsWith('@') && parts.length > 2 && (parts[2] == 'INDI' || parts[2] == 'FAM')) {
                currentRecord = {
                    'id': tag.replaceAll('@', ''), 'type': parts[2],
                    'notes': <dynamic>[], 'sour': <dynamic>[], 'photos': <dynamic>[], 'fams': <dynamic>[],
                };
            }
        } else if (currentRecord != null) {
            if (level == 1) {
                currentEvent = null;
                switch(tag) {
                    case 'NAME':
                      final nameParts = value.split('/');
                      currentRecord['givn'] = nameParts.isNotEmpty ? nameParts[0].trim() : '';
                      currentRecord['surn'] = nameParts.length > 1 ? nameParts[1].trim() : '';
                      currentRecord['name'] = value.replaceAll('/', '').trim();
                      break;
                    case 'HUSB': case 'WIFE': case 'CHIL':
                      final key = '${tag.toLowerCase()}s';
                      if (!currentRecord.containsKey(key)) currentRecord[key] = <dynamic>[];
                      (currentRecord[key] as List<dynamic>).add(value.replaceAll('@', ''));
                      break;
                    case 'FAMC':
                        currentEvent = {'id': value.replaceAll('@', '')};
                        currentRecord['famc'] = currentEvent;
                        break;
                    case 'FAMS':
                      (currentRecord['fams'] as List<dynamic>).add(value.replaceAll('@', ''));
                      break;
                    case 'BIRT': case 'DEAT': case 'MARR': case 'BURI': case 'ADOP':
                        currentEvent = <String, dynamic>{};
                        if (value.isNotEmpty) currentEvent['value'] = value;
                        currentRecord[tag.toLowerCase()] = currentEvent;
                        break;
                    case 'OBJE':
                        currentEvent = <String, dynamic>{};
                        (currentRecord['photos'] as List).add(currentEvent);
                        break;
                    case 'NOTE':
                        var tuple = _processMultiLine(lines, i);
                        (currentRecord['notes'] as List).add(tuple.item1);
                        i = tuple.item2;
                        break;
                    case 'SOUR':
                        (currentRecord['sour'] as List<dynamic>).add(value);
                        break;
                    default:
                      currentRecord[tag.toLowerCase()] = value;
                      break;
                }
            } else if (level == 2) {
                if (tag == 'NOTE') {
                    var tuple = _processMultiLine(lines, i);
                    if (currentEvent != null) {
                        currentEvent['note'] = tuple.item1;
                    }
                    i = tuple.item2;
                } else if (currentEvent != null) {
                    if (tag == 'PLAC') {
                      final placeValue = value.trim();
                      currentEvent['plac'] = placeValue;
                      if (placeValue.isNotEmpty) uniquePlaces.add(placeValue);
                    } else {
                       currentEvent[tag.toLowerCase().replaceAll('_', '')] = value;
                    }
                }
            }
        }
    }
    if (currentRecord != null) _saveRecord(currentRecord);

    _crossReferenceChildren();
    _updateFamilyNames();
    if (kDebugMode) {
      print('Finished parsing. Found ${individuals.length} individuals and ${families.length} families.');
    }
  }

  ({String item1, int item2}) _processMultiLine(List<String> lines, int currentIndex) {
      final content = StringBuffer();
      
      var line = lines[currentIndex].trim();
      var initialParts = line.split(' ');
      if (initialParts.length > 2) {
        content.write(line.substring(line.indexOf(initialParts[1]) + initialParts[1].length + 1));
      }

      int i = currentIndex + 1;
      while (i < lines.length) {
          line = lines[i].trim();
          if (line.isEmpty) {
              i++;
              continue;
          }

          final parts = line.split(' ');
          final level = int.tryParse(parts[0]);
          
          if (level != null && level <= 2) {
              return (item1: content.toString(), item2: i - 1); 
          }

          if (level == null) {
            content.write('\n');
            content.write(line);
          } else {
            final tag = parts.length > 1 ? parts[1] : '';
            int valueStartIndex = line.indexOf(tag) + tag.length + 1;

            if (tag == 'CONC') {
                if (valueStartIndex <= line.length) {
                   content.write(line.substring(valueStartIndex));
                }
            } else {
                content.write('\n');
                if (tag == 'CONT') {
                    if (valueStartIndex <= line.length) {
                        content.write(line.substring(valueStartIndex));
                    }
                } else {
                    valueStartIndex = line.indexOf(parts[0]) + parts[0].length + 1;
                    if (valueStartIndex <= line.length) {
                        content.write(line.substring(valueStartIndex));
                    }
                }
            }
          }
          i++;
      }
      return (item1: content.toString(), item2: i - 1);
  }

  void _saveRecord(Map<String, dynamic> record) {
    if (record['type'] == 'INDI') {
      final famc = record['famc'];
      if (famc is Map) {
        record['famc'] = famc['id'];
        if (famc.containsKey('pedi')) {
          record['pedi'] = famc['pedi'];
        }
      }
      individuals[record['id'] as String] = record;
    } else if (record['type'] == 'FAM') {
      families.add(record);
    }
  }

  void _crossReferenceChildren() {
    final famcMap = <String, List<dynamic>>{};
    individuals.forEach((id, indi) {
      final famcId = indi['famc'];
      if (famcId != null && famcId is String) {
        if (!famcMap.containsKey(famcId)) {
          famcMap[famcId] = <dynamic>[];
        }
        famcMap[famcId]!.add(id);
      }
    });

    for (var family in families) {
      final famId = family['id'] as String;
      if (famcMap.containsKey(famId)) {
        final childrenFromFamc = famcMap[famId]!;
        if (!family.containsKey('chils')) {
          family['chils'] = <dynamic>[];
        }
        final existingChildren = family['chils'] as List<dynamic>;
        for (var childId in childrenFromFamc) {
          if (!existingChildren.contains(childId)) {
            existingChildren.add(childId);
          }
        }
      }
    }
  }

  void _updateFamilyNames() {
    for (var family in families) {
      final husbandIds = family['husbs'] as List<dynamic>? ?? [];
      final wifeIds = family['wifes'] as List<dynamic>? ?? [];

      String familyName = '';
      if (husbandIds.isNotEmpty) {
        final husband = individuals[husbandIds.first];
        if (husband != null && husband['surn'] != null) {
          final surnames = (husband['surn'] as String).split(' ');
          familyName += surnames.isNotEmpty ? surnames.first : '';
        }
      }
      if (wifeIds.isNotEmpty) {
        final wife = individuals[wifeIds.first];
        if (wife != null && wife['surn'] != null) {
          if (familyName.isNotEmpty) {
            familyName += ' - ';
          }
          final surnames = (wife['surn'] as String).split(' ');
          familyName += surnames.isNotEmpty ? surnames.first : '';
        }
      }
      family['name'] = familyName.isNotEmpty ? familyName : 'Family';
    }
  }
}
