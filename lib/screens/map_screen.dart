import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:genealogic/gedcom_parser.dart';
import 'package:genealogic/providers/gedcom_provider.dart';
import 'package:genealogic/screens/person_detail_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Map<String, LatLng> _locations = {};

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final jsonString = await rootBundle.loadString('assets/data/locations.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    setState(() {
      _locations = jsonMap.map((key, value) =>
          MapEntry(key, LatLng(value['latitude'], value['longitude'])));
    });
  }

  List<Map<String, dynamic>> _getEventsForPlace(GedcomParser parser, String placeName) {
    final events = <Map<String, dynamic>>[];
    for (var individual in parser.individuals.values) {
      if (individual['birt']?['plac'] == placeName) {
        events.add({
          'type': 'Naixement',
          'date': individual['birt']?['date'] ?? 'N/A',
          'data': individual
        });
      }
      if (individual['deat']?['plac'] == placeName) {
        events.add({
          'type': 'Defunció',
          'date': individual['deat']?['date'] ?? 'N/A',
          'data': individual
        });
      }
    }
    for (var family in parser.families) {
      if (family['marr']?['plac'] == placeName) {
        events.add({
          'type': 'Matrimoni',
          'date': family['marr']?['date'] ?? 'N/A',
          'data': family
        });
      }
    }
    return events;
  }

  void _showEventsForLocation(
      BuildContext context, GedcomParser parser, String placeName, List<Map<String, dynamic>> events) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                placeName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final type = event['type'];
                    final date = event['date'];
                    final data = event['data'];
                    String title;
                    IconData icon;
                    Map<String, dynamic>? individualToShow;

                    if (type == 'Naixement') {
                      title = data['name'] ?? 'N/A';
                      icon = Icons.child_friendly;
                      individualToShow = data;
                    } else if (type == 'Defunció') {
                      title = data['name'] ?? 'N/A';
                      icon = Icons.book;
                      individualToShow = data;
                    } else { // Matrimoni
                      final husband = parser.individuals[data['husbs']?.first];
                      final wife = parser.individuals[data['wifes']?.first];
                      title = '${husband?['name'] ?? ''} & ${wife?['name'] ?? ''}';
                      icon = Icons.favorite;
                      // Per ara, no fem res al clicar en un matrimoni
                    }

                    return ListTile(
                      leading: Icon(icon),
                      title: Text(title),
                      subtitle: Text('$type - $date'),
                      onTap: individualToShow != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PersonDetailScreen(
                                    person: individualToShow!,
                                  ),
                                ),
                              );
                            }
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Marker> _getMarkers(GedcomParser parser) {
    final markers = <Marker>[];

    _locations.forEach((place, latLng) {
      final events = _getEventsForPlace(parser, place);

      if (events.isNotEmpty) {
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: latLng,
            child: GestureDetector(
              onTap: () {
                _showEventsForLocation(context, parser, place, events);
              },
              child: const Icon(Icons.location_pin, color: Colors.deepOrange, size: 40.0),
            ),
          ),
        );
      }
    });
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final parser = Provider.of<GedcomProvider>(context).parser;
    if (parser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa d\'esdeveniments'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final markers = _getMarkers(parser);
    LatLng initialCenter;
    if (markers.isNotEmpty) {
      initialCenter = markers.first.point;
    } else {
      initialCenter = LatLng(39.5696, 2.6502); // Default to Palma de Mallorca
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa d\'esdeveniments'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: 9.2,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          if (markers.isNotEmpty)
            MarkerLayer(
              markers: markers,
            ),
          if (markers.isEmpty && _locations.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (markers.isEmpty)
            const Center(child: Text('No s\'han trobat esdeveniments amb ubicació.'))
        ],
      ),
    );
  }
}
