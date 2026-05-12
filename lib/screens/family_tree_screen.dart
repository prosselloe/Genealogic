import 'package:flutter/material.dart';
import 'package:genealogic/providers/gedcom_provider.dart';
import 'package:genealogic/screens/family_detail_screen.dart';
import 'package:genealogic/screens/family_relations_screen.dart';
import 'package:genealogic/screens/info_screen.dart';
import 'package:genealogic/screens/map_screen.dart';
import 'package:genealogic/widgets/heraldic_shield_widget.dart';
import 'package:provider/provider.dart';
import 'package:genealogic/gedcom_parser.dart';
import 'package:genealogic/main.dart';

class FamilyTreeScreen extends StatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  String? _selectedSurname;

  @override
  Widget build(BuildContext context) {
    final gedcomProvider = Provider.of<GedcomProvider>(context);
    final parser = gedcomProvider.parser!;
    final surnames = gedcomProvider.surnames;
    final themeProvider = Provider.of<ThemeProvider>(context);


    final filteredFamilies = parser.families.where((family) {
      final familyName = family['name'] as String? ?? '';

      if (!familyName.contains(' - ')) return false;
      final parts = familyName.split(' - ');
      if (parts.length != 2 ||
          parts[0].trim().isEmpty ||
          parts[1].trim().isEmpty) {
        return false;
      }

      final husbandIds = family['husbs'] as List<String>? ?? [];
      final wifeIds = family['wifes'] as List<String>? ?? [];
      if (husbandIds.isEmpty || wifeIds.isEmpty) {
        return false;
      }

      if (_selectedSurname == null || _selectedSurname == 'Tots') {
        return true;
      }

      final firstSurname = parts[0].trim();
      final secondSurname = parts[1].trim();

      return firstSurname.toLowerCase() == _selectedSurname!.toLowerCase() ||
          secondSurname.toLowerCase() == _selectedSurname!.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arbres familiars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
            tooltip: themeProvider.themeMode == ThemeMode.dark ? 'Tema clar' : 'Tema fosc',
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open, color: Colors.white),
            onPressed: () => gedcomProvider.loadGedcomFromFile(),
          ),
          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _IndividualSearchDelegate(
                    parser, parser.individuals.values.toList()),
              );
            },
          ),
          if (surnames.isNotEmpty)
            DropdownButton<String>(
              value: _selectedSurname ?? 'Tots',
              icon: const Icon(Icons.filter_list, color: Colors.white),
              dropdownColor: Theme.of(context).appBarTheme.backgroundColor,
              style: const TextStyle(color: Colors.white),
              underline: Container(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSurname = newValue;
                });
              },
              items: surnames.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredFamilies.length,
        itemBuilder: (context, index) {
          final family = filteredFamilies[index];
          final familyName = family['name'] as String;
          final surnames = familyName.split(' - ').map((s) => s.trim()).toList();
          final firstSurname = surnames[0];
          final secondSurname = surnames[1];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HeraldicShieldWidget(surname: firstSurname),
                  Text(firstSurname,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text(' - ', style: TextStyle(fontSize: 16)),
                  Text(secondSurname,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  HeraldicShieldWidget(surname: secondSurname),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('ID: ${family['id']}'),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FamilyRelationsScreen(family: family),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _IndividualSearchDelegate extends SearchDelegate<String> {
  final GedcomParser parser;
  final List<Map<String, dynamic>> individuals;

  _IndividualSearchDelegate(this.parser, this.individuals);

  @override
  String get searchFieldLabel => 'Cerca individus';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.brightness == Brightness.dark
            ? Colors.grey[900]
            : const Color(0xFF212121),
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final suggestions = individuals.where((individual) {
      final name = individual['name'] as String? ?? '';
      return name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final individual = suggestions[index];
          final name = individual['name'] as String;

          final photos =
              individual['photos'] as List<Map<String, dynamic>>? ?? [];
          final photoUrl =
              photos.isNotEmpty ? photos.first['file'] as String? : null;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage: (photoUrl != null &&
                        Uri.tryParse(photoUrl)?.isAbsolute == true)
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null ||
                        Uri.tryParse(photoUrl)?.isAbsolute != true)
                    ? Icon(Icons.person, size: 24, color: Colors.grey[600])
                    : null,
              ),
              title: Text(name),
              onTap: () {
                final familyId = individual['famc'] as String? ??
                    (individual['fams'] as List<String>?)?.first;
                if (familyId != null) {
                  final family = parser.families.firstWhere(
                      (f) => f['id'] == familyId,
                      orElse: () => <String, dynamic>{});
                  if (family.isNotEmpty) {
                    close(context, individual['id'] ?? '');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FamilyDetailScreen(family: family),
                      ),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}
