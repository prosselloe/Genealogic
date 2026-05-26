import 'dart:io';
import 'dart:convert';
import 'package:genealogic_balear/gedcom_parser.dart';

Future<void> main() async {
  final file = File('assets/data/myheritage.ged');
  final content = await file.readAsString();
  final parser = GedcomParser();
  await parser.parse(content);
  
  final locations = <String, Map<String, double?>>{};
  for (var place in parser.uniquePlaces) {
    locations[place] = {'lat': null, 'lon': null};
  }

  final jsonFile = File('assets/data/locations.json');
  await jsonFile.writeAsString(jsonEncode(locations));

  // ignore: avoid_print
  print('Generated ${locations.length} locations to assets/data/locations.json');
}
