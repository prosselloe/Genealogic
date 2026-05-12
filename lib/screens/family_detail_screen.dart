import 'package:flutter/material.dart';
import 'package:genealogic/models/person.dart';
import 'package:genealogic/providers/gedcom_provider.dart';
import 'package:genealogic/screens/person_detail_screen.dart';
import 'package:graphview/GraphView.dart';
import 'package:provider/provider.dart';
import '../gedcom_parser.dart';

class FamilyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> family;

  const FamilyDetailScreen({super.key, required this.family});

  @override
  FamilyDetailScreenState createState() => FamilyDetailScreenState();
}

class FamilyDetailScreenState extends State<FamilyDetailScreen> {
  late Graph _graph;
  final SugiyamaAlgorithm _algorithm = SugiyamaAlgorithm(SugiyamaConfiguration()
    ..nodeSeparation = 50
    ..levelSeparation = 100
    ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM);

  @override
  void initState() {
    super.initState();
    _graph = Graph();
    final parser = Provider.of<GedcomProvider>(context, listen: false).parser!;
    _buildGraphForFamily(parser, widget.family);
  }

  void _buildGraphForFamily(GedcomParser parser, Map<String, dynamic> family) {
    final familyId = family['id'] as String;
    final familyNode = Node.Id(familyId);
    _graph.addNode(familyNode);

    final husbandIds = family['husbs'] as List<String>? ?? [];
    final wifeIds = family['wifes'] as List<String>? ?? [];

    for (var husbandId in husbandIds) {
      final husbandNode = Node.Id(husbandId);
      _graph.addNode(husbandNode);
      _graph.addEdge(husbandNode, familyNode);
      _addParents(parser, husbandId, husbandNode);
    }

    for (var wifeId in wifeIds) {
      final wifeNode = Node.Id(wifeId);
      _graph.addNode(wifeNode);
      _graph.addEdge(wifeNode, familyNode);
      _addParents(parser, wifeId, wifeNode);
    }

    final childrenIds = family['chils'] as List<String>? ?? [];
    for (var childId in childrenIds) {
      final childNode = Node.Id(childId);
      _graph.addNode(childNode);
      _graph.addEdge(familyNode, childNode);
    }
  }

  void _addParents(GedcomParser parser, String personId, Node personNode) {
    final individual = parser.individuals[personId];
    if (individual == null || individual['famc'] == null) {
      return;
    }

    final parentFamilyId = individual['famc'] as String;
    final parentFamily = parser.families.firstWhere(
        (f) => f['id'] == parentFamilyId, orElse: () => <String, dynamic>{});

    if (parentFamily.isNotEmpty) {
      final parentFamilyNode = Node.Id(parentFamilyId);
      _graph.addNode(parentFamilyNode);
      _graph.addEdge(parentFamilyNode, personNode);

      final fatherIds = parentFamily['husbs'] as List<String>? ?? [];
      final motherIds = parentFamily['wifes'] as List<String>? ?? [];

      for (var fatherId in fatherIds) {
        final fatherNode = Node.Id(fatherId);
        _graph.addNode(fatherNode);
        _graph.addEdge(fatherNode, parentFamilyNode);
      }

      for (var motherId in motherIds) {
        final motherNode = Node.Id(motherId);
        _graph.addNode(motherNode);
        _graph.addEdge(motherNode, parentFamilyNode);
      }
    }
  }

  void _navigateToFamily(Map<String, dynamic> family) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyDetailScreen(family: family),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parser = Provider.of<GedcomProvider>(context).parser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.family['name'] ?? 'Detall de la família'),
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.1,
        maxScale: 2.0,
        child: GraphView(
          graph: _graph,
          algorithm: _algorithm,
          paint: Paint()
            ..color = Theme.of(context).colorScheme.secondary
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke,
          builder: (Node node) {
            final id = node.key!.value as String;
            if (id.startsWith('F')) {
              return const SizedBox.shrink();
            }
            return _buildPersonNodeWidget(parser, id);
          },
        ),
      ),
    );
  }

  String _extractYear(String? date) {
    if (date == null) return '';
    final yearMatch = RegExp(r'\b(\d{4})\b').firstMatch(date);
    return yearMatch?.group(1) ?? '';
  }

  Widget _buildPersonNodeWidget(GedcomParser parser, String id) {
    final individualData = parser.individuals[id];
    if (individualData == null) {
      return Container();
    }

    final person = Person.fromMap(individualData);
    final photo = person.photos.isNotEmpty ? person.photos.first : null;
    final photoUrl = photo?.url;
    final isAdopted = individualData.containsKey('pedi') && individualData['pedi'] == 'Adopted';

    final birthYear = _extractYear(person.birthDate);
    final deathYear = _extractYear(person.deathDate);

    String yearInfo = '';
    if (birthYear.isNotEmpty) {
      yearInfo = '($birthYear';
      if (deathYear.isNotEmpty) {
        yearInfo += '-$deathYear)';
      } else {
        yearInfo += ')';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonDetailScreen(person: individualData),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (person.famc != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () {
                      final parentFamily = parser.families.firstWhere(
                          (f) => f['id'] == person.famc, orElse: () => <String, dynamic>{});
                      if (parentFamily.isNotEmpty) {
                        _navigateToFamily(parentFamily);
                      }
                    },
                  )
                else
                  const SizedBox(width: 48),
                if (person.fams.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: () {
                      final spouseFamily = parser.families.firstWhere(
                          (f) => f['id'] == person.fams.first, orElse: () => <String, dynamic>{});
                      if (spouseFamily.isNotEmpty) {
                        _navigateToFamily(spouseFamily);
                      }
                    },
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
            if (photoUrl != null && Uri.tryParse(photoUrl)?.isAbsolute == true)
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(photoUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: Icon(Icons.person, size: 40, color: Colors.grey[600]),
              ),
            Text(
              person.name,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            if (yearInfo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  yearInfo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                      ),
                ),
              ),
            if (isAdopted)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  '(Adoptat/da)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
