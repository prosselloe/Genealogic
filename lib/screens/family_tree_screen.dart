import 'package:flutter/material.dart';
import 'package:genealogic_balear/models/person.dart';
import 'package:genealogic_balear/providers/gedcom_provider.dart';
import 'package:genealogic_balear/screens/converter_screen.dart';
import 'package:genealogic_balear/screens/family_detail_screen.dart';
import 'package:genealogic_balear/screens/family_relations_screen.dart';
import 'package:genealogic_balear/screens/info_screen.dart';
import 'package:genealogic_balear/screens/map_screen.dart';
import 'package:genealogic_balear/widgets/cropped_image_widget.dart';
import 'package:genealogic_balear/widgets/heraldic_shield_widget.dart';
import 'package:provider/provider.dart';
import 'package:genealogic_balear/gedcom_parser.dart';
import 'package:genealogic_balear/main.dart';

class FamilyTreeScreen extends StatefulWidget {
  final String? highlightedPersonId;
  const FamilyTreeScreen({super.key, this.highlightedPersonId});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  String? _selectedSurname;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.highlightedPersonId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToHighlightedPerson();
      });
    }
  }

  void _scrollToHighlightedPerson() {
    final gedcomProvider = Provider.of<GedcomProvider>(context, listen: false);
    final parser = gedcomProvider.parser!;
    final families = parser.families;

    int? targetIndex;

    for (int i = 0; i < families.length; i++) {
      final family = families[i];
      final husbandIds = family['husbs'] as List<dynamic>? ?? [];
      final wifeIds = family['wifes'] as List<dynamic>? ?? [];
      final childIds = family['chils'] as List<dynamic>? ?? [];

      if (husbandIds.contains(widget.highlightedPersonId) ||
          wifeIds.contains(widget.highlightedPersonId) ||
          childIds.contains(widget.highlightedPersonId)) {
        targetIndex = i;
        break;
      }
    }

    if (targetIndex != null) {
      // Approximate height of each item, adjust as needed
      const double itemHeight = 100.0;
      final double offset = targetIndex * itemHeight;

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

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

      final husbandIds = family['husbs'] as List<dynamic>? ?? [];
      final wifeIds = family['wifes'] as List<dynamic>? ?? [];
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
            icon: Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Colors.white),
            tooltip: themeProvider.themeMode == ThemeMode.dark
                ? 'Tema clar'
                : 'Tema fosc',
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.transform, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ConverterScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open, color: Colors.white),
            tooltip: 'Obrir fitxer GEDCOM',
            onPressed: () => gedcomProvider.loadGedcomFromFile(),
          ),
          IconButton(
            icon: const Icon(Icons.restore, color: Colors.white),
            tooltip: 'Recarregar dades inicials',
            onPressed: () => gedcomProvider.loadInitialData(),
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
        controller: _scrollController,
        itemCount: filteredFamilies.length,
        itemBuilder: (context, index) {
          final family = filteredFamilies[index];
          final familyName = family['name'] as String;
          final surnames =
              familyName.split(' - ').map((s) => s.trim()).toList();
          final firstSurname = surnames[0];
          final secondSurname = surnames[1];

          final husbandIds = family['husbs'] as List<dynamic>? ?? [];
          final wifeIds = family['wifes'] as List<dynamic>? ?? [];
          final childIds = family['chils'] as List<dynamic>? ?? [];

          bool isHighlighted = false;
          if (widget.highlightedPersonId != null) {
            isHighlighted = husbandIds.contains(widget.highlightedPersonId) ||
                wifeIds.contains(widget.highlightedPersonId) ||
                childIds.contains(widget.highlightedPersonId);
          }

          return Card(
            color: isHighlighted ? Theme.of(context).highlightColor : null,
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

  String _surnameFilter = '';
  String _startDateFilter = '';
  String _endDateFilter = '';
  String _sortCriteria = 'id'; // Default sort by ID

  final _surnameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  _IndividualSearchDelegate(this.parser, this.individuals);

  @override
  void close(BuildContext context, String result) {
    _surnameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.close(context, result);
  }

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
          showSuggestions(context);
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

  String? _getEventDate(Map<String, dynamic>? event) {
    if (event == null) return null;
    return event['date'] as String?;
  }

  Widget _buildSearchResults(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final suggestions = individuals.where((individual) {
          final name = individual['givn'] as String? ?? '';
          final surname = individual['surn'] as String? ?? '';

          final birthDate =
              _getYearFromDate(_getEventDate(individual['birt']));
          final deathDate =
              _getYearFromDate(_getEventDate(individual['deat']));

          final queryMatch = query.isEmpty ||
              name.toLowerCase().contains(query.toLowerCase()) ||
              surname.toLowerCase().contains(query.toLowerCase());
          final surnameMatch = _surnameFilter.isEmpty ||
              surname.toLowerCase().contains(_surnameFilter.toLowerCase());

          final startDate = int.tryParse(_startDateFilter);
          final endDate = int.tryParse(_endDateFilter);

          bool dateMatch = true;
          if (startDate != null || endDate != null) {
            final sDate = startDate ?? -9999;
            final eDate = endDate ?? 9999;

            final bDate = birthDate;
            final dDate = deathDate;

            if (bDate != null && dDate != null) {
              dateMatch = (bDate >= sDate && bDate <= eDate) ||
                  (dDate >= sDate && dDate <= eDate) ||
                  (bDate <= sDate && dDate >= eDate);
            } else if (bDate != null) {
              dateMatch = bDate >= sDate && bDate <= eDate;
            } else if (dDate != null) {
              dateMatch = dDate >= sDate && dDate <= eDate;
            } else {
              dateMatch = false;
            }
          }

          return queryMatch && surnameMatch && dateMatch;
        }).toList();

        suggestions.sort((a, b) {
          if (_sortCriteria == 'id') {
            return (a['id'] as String? ?? '')
                .compareTo(b['id'] as String? ?? '');
          } else if (_sortCriteria == 'surname') {
            return (a['surn'] as String? ?? '')
                .compareTo(b['surn'] as String? ?? '');
          } else if (_sortCriteria == 'birth') {
            final birthA = _getYearFromDate(_getEventDate(a['birt']));
            final birthB = _getYearFromDate(_getEventDate(b['birt']));
            if (birthA != null && birthB != null) {
              return birthA.compareTo(birthB);
            } else if (birthA != null) {
              return -1;
            } else if (birthB != null) {
              return 1;
            }
            return 0;
          } else if (_sortCriteria == 'death') {
            final deathA = _getYearFromDate(_getEventDate(a['deat']));
            final deathB = _getYearFromDate(_getEventDate(b['deat']));
            if (deathA != null && deathB != null) {
              return deathA.compareTo(deathB);
            } else if (deathA != null) {
              return -1;
            } else if (deathB != null) {
              return 1;
            }
            return 0;
          }
          return 0;
        });

        return Column(
          children: [
            _buildFilterAndSortControls(context, setState),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final individual = suggestions[index];
                    final person = Person.fromMap(individual);

                    final displayablePhotos = person.photos;

                    Widget leadingWidget;

                    if (displayablePhotos.isEmpty) {
                      leadingWidget = CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, size: 24, color: Colors.grey[600]),
                      );
                    } else {
                      final photoToShow = displayablePhotos.firstWhere(
                        (p) => p.isPersonal,
                        orElse: () => displayablePhotos.first,
                      );

                      leadingWidget = CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: ClipOval(
                          child: CroppedImageWidget(
                            photo: photoToShow,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }

                    final birthDate = _getEventDate(individual['birt']);
                    final deathDate = _getEventDate(individual['deat']);
                    String subtitle = '';
                    if (birthDate != null && birthDate.isNotEmpty) {
                      subtitle += '⚬ ${birthDate.trim()}';
                    }
                    if (deathDate != null && deathDate.isNotEmpty) {
                      subtitle += (subtitle.isNotEmpty
                          ? ' / ✝ ${deathDate.trim()}'
                          : '✝ ${deathDate.trim()}');
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: leadingWidget,
                        title: Text('${person.id}: ${person.name}'.trim()),
                        subtitle:
                            Text(subtitle.isEmpty ? 'Sense dates' : subtitle),
                        onTap: () {
                          final famsList =
                              individual['fams'] as List<dynamic>?;
                          final familyId = individual['famc'] as String? ??
                              (famsList != null && famsList.isNotEmpty
                                  ? famsList.first as String?
                                  : null);
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
              ),
            )
          ],
        );
      },
    );
  }

  int? _getYearFromDate(String? date) {
    if (date == null) return null;
    final yearMatch = RegExp(r'(\d{4})').firstMatch(date);
    return yearMatch != null ? int.tryParse(yearMatch.group(1)!) : null;
  }

  Widget _buildFilterAndSortControls(
      BuildContext context, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Llinatge'),
                  onChanged: (value) {
                    setState(() => _surnameFilter = value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _startDateController,
                  decoration: const InputDecoration(labelText: 'Any inici'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() => _startDateFilter = value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _endDateController,
                  decoration: const InputDecoration(labelText: 'Any fi'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() => _endDateFilter = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => _sortCriteria = 'id'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _sortCriteria == 'id'
                              ? Theme.of(context).colorScheme.primary
                              : null),
                      child: const Text('ID'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _sortCriteria = 'surname'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _sortCriteria == 'surname'
                              ? Theme.of(context).colorScheme.primary
                              : null),
                      child: const Text('Llinatge'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _sortCriteria = 'birth'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _sortCriteria == 'birth'
                              ? Theme.of(context).colorScheme.primary
                              : null),
                      child: const Text('Naixement'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _sortCriteria = 'death'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _sortCriteria == 'death'
                              ? Theme.of(context).colorScheme.primary
                              : null),
                      child: const Text('Defunció'),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _surnameController.clear();
                    _startDateController.clear();
                    _endDateController.clear();
                    _surnameFilter = '';
                    _startDateFilter = '';
                    _endDateFilter = '';
                    _sortCriteria = 'id'; // Reset to ID
                  });
                },
                child: const Text('Netejar'),
              ),
            ],
          )
        ],
      ),
    );
  }
}