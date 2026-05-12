import 'dart:convert';
import 'dart:io';
import 'package:genealogic/gedcom_parser.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer' as developer;

void main() async {
  final gedcomData = await File('assets/data/myheritage.ged').readAsString();
  final parser = GedcomParser();
  await parser.parse(gedcomData);

  final locations = <String, Map<String, double>>{};

  for (final place in parser.uniquePlaces) {
    try {
      final locationData = await locationFromAddress(place);
      if (locationData.isNotEmpty) {
        locations[place] = {
          'latitude': locationData.first.latitude,
          'longitude': locationData.first.longitude,
        };
      }
    } catch (e, s) {
      developer.log('Could not geocode "$place"', name: 'create_locations_json', error: e, stackTrace: s);
    }
  }

  final jsonString = json.encode(locations);
  await File('assets/locations.json').writeAsString(jsonString);

  developer.log('locations.json created successfully.', name: 'create_locations_json');
}
