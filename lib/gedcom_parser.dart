import 'dart:developer' as developer;

class GedcomParser {
  final Map<String, Map<String, dynamic>> individuals = {};
  final List<Map<String, dynamic>> families = [];
  final Set<String> uniquePlaces = <String>{};

  Future<void> parse(String gedcomData) async {
    developer.log('Starting GEDCOM parsing...', name: 'GedcomParser.parse');

    final lines = gedcomData.split('\n');
    Map<String, dynamic>? currentRecord;
    Map<String, dynamic>? currentEvent;
    String? currentEventTag;
    Map<String, dynamic>? currentFamc;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      final parts = line.split(' ');
      final level = int.tryParse(parts[0]);
      if (level == null) continue;

      final tag = parts.length > 1 ? parts[1] : '';
      final value = parts.length > 2 ? parts.sublist(2).join(' ') : '';

      if (level == 0) {
        if (currentRecord != null) {
          _saveRecord(currentRecord);
        }

        if (tag.startsWith('@') && parts.length > 2) {
          final recordType = parts[2];
          if (recordType == 'INDI' || recordType == 'FAM') {
            currentRecord = {
              'id': tag.replaceAll('@', ''),
              'type': recordType,
              'notes': <String>[],
              'sour': <String>[],
              'photos': <Map<String, dynamic>>[],
              'fams': <String>[],
            };
          } else {
            currentRecord = null;
          }
        } else {
          currentRecord = null;
        }
        currentEvent = null;
        currentEventTag = null;
        currentFamc = null;
      } else if (currentRecord != null) {
        if (level == 1) {
          currentFamc = null;

          switch (tag) {
            case 'NAME':
              final nameParts = value.split('/');
              if (nameParts.length >= 2) {
                currentRecord['givn'] = nameParts[0].trim();
                currentRecord['surn'] = nameParts[1].trim();
                currentRecord['name'] =
                    '${currentRecord['givn']} ${currentRecord['surn']}'.trim();
              } else {
                currentRecord['name'] = value.replaceAll('/', '').trim();
              }
              currentEvent = null;
              currentEventTag = null;
              break;
            case 'HUSB':
            case 'WIFE':
            case 'CHIL':
              final key = '${tag.toLowerCase()}s';
              if (!currentRecord.containsKey(key)) {
                currentRecord[key] = <String>[];
              }
              (currentRecord[key] as List<String>)
                  .add(value.replaceAll('@', ''));
              currentEvent = null;
              currentEventTag = null;
              break;
            case 'FAMC':
              currentFamc = {'id': value.replaceAll('@', '')};
              currentRecord['famc'] = currentFamc;
              currentEvent = null;
              currentEventTag = null;
              break;
            case 'FAMS':
              (currentRecord['fams'] as List<String>)
                  .add(value.replaceAll('@', ''));
              currentEvent = null;
              currentEventTag = null;
              break;
            case 'BIRT':
            case 'DEAT':
            case 'MARR':
            case 'ADOP':
            case 'BAPM':
            case 'BURI':
            case 'CENS':
            case 'CHR':
            case 'CONF':
            case 'CREM':
            case 'DIV':
            case 'EMIG':
            case 'ENGA':
            case 'GRAD':
            case 'IMMI':
            case 'NATU':
            case 'ORDN':
            case 'PROB':
            case 'RETI':
            case 'WILL':
              currentEventTag = tag.toLowerCase();
              currentEvent = <String, dynamic>{};
               if (value.isNotEmpty) {
                currentEvent['value'] = value;
              }
              currentRecord[currentEventTag] = currentEvent;
              break;
            case 'OBJE':
              currentEventTag = 'obje';
              currentEvent = <String, dynamic>{};
              currentRecord['photos'] =
                  (currentRecord['photos'] as List)..add(currentEvent);
              break;
            case 'SOUR':
              (currentRecord['sour'] as List<String>).add(value);
              currentEvent = null;
              currentEventTag = null;
              break;
            case 'NOTE':
              (currentRecord['notes'] as List<String>).add(value);
              currentEvent = null;
              currentEventTag = null;
              break;
            default:
              currentRecord[tag.toLowerCase()] = value;
              break;
          }
        } else if (level == 2) {
          if (currentEvent != null) {
            if (tag == 'PLAC') {
              final placeValue = value.trim();
              currentEvent['plac'] = placeValue;
              if (placeValue.isNotEmpty) uniquePlaces.add(placeValue);
            } else {
              currentEvent[tag.toLowerCase().replaceAll('_', '')] = value;
            }
          } else if (currentFamc != null && tag == 'PEDI') {
            currentFamc[tag.toLowerCase()] = value;
          }
        }
      }
    }

    if (currentRecord != null) {
      _saveRecord(currentRecord);
    }

    _crossReferenceChildren();
    _updateFamilyNames();

    developer.log(
        'Finished parsing. Found ${individuals.length} individuals and ${families.length} families.',
        name: 'GedcomParser.parse');
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
    final famcMap = <String, List<String>>{};
    individuals.forEach((id, indi) {
      final famcId = indi['famc'];
      if (famcId != null && famcId is String) {
        if (!famcMap.containsKey(famcId)) {
          famcMap[famcId] = [];
        }
        famcMap[famcId]!.add(id);
      }
    });

    for (var family in families) {
      final famId = family['id'] as String;
      if (famcMap.containsKey(famId)) {
        final childrenFromFamc = famcMap[famId]!;
        if (!family.containsKey('chils')) {
          family['chils'] = <String>[];
        }
        final existingChildren = family['chils'] as List<String>;
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
      final husbandIds = family['husbs'] as List<String>? ?? [];
      final wifeIds = family['wifes'] as List<String>? ?? [];

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
