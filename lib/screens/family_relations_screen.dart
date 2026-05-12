import 'package:flutter/material.dart';
import 'package:genealogic/gedcom_parser.dart';
import 'package:genealogic/providers/gedcom_provider.dart';
import 'package:genealogic/screens/family_detail_screen.dart';
import 'package:genealogic/widgets/heraldic_shield_widget.dart';
import 'package:graphview/GraphView.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';

class FamilyRelationsScreen extends StatelessWidget {
  final Map<String, dynamic> family;

  const FamilyRelationsScreen({
    super.key,
    required this.family,
  });

  @override
  Widget build(BuildContext context) {
    final parser = Provider.of<GedcomProvider>(context).parser!;
    final Graph graph = _buildGraph(parser);
    final algorithm = SugiyamaAlgorithm(SugiyamaConfiguration()
      ..nodeSeparation = 50
      ..levelSeparation = 100
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM);

    return Scaffold(
      appBar: AppBar(
        title: Text(family['name'] as String? ?? 'Relacions familiars'),
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.1,
        maxScale: 2.0,
        child: GraphView(
          graph: graph,
          algorithm: algorithm,
          paint: Paint()
            ..color = Theme.of(context).colorScheme.secondary
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
          builder: (Node node) {
            final familyNode = node.key!.value as Map<String, dynamic>;
            return _buildFamilyNode(context, parser, familyNode);
          },
        ),
      ),
    );
  }

  Graph _buildGraph(GedcomParser parser) {
    final graph = Graph();
    final Map<String, Node> nodes = {};

    // Helper to get or create a node
    Node getNode(Map<String, dynamic> fam) {
      final famId = fam['id'] as String;
      if (!nodes.containsKey(famId)) {
        nodes[famId] = Node.Id(fam);
      }
      return nodes[famId]!;
    }

    final currentNode = getNode(family);

    // Add parent families and edges
    final parentFamilies = _getParentFamiliesFor(parser, family);
    for (var parentFam in parentFamilies) {
      final parentNode = getNode(parentFam);
      graph.addEdge(parentNode, currentNode);
    }

    // Add child families and edges
    final childFamilies = _getChildFamiliesFor(parser, family);
    for (var childFam in childFamilies) {
      final childNode = getNode(childFam);
      graph.addEdge(currentNode, childNode);
    }

    // If no connections, just add the central node
    if (graph.edges.isEmpty) {
      graph.addNode(currentNode);
    }

    return graph;
  }

  String _getSurname(String? fullName) {
    try {
      if (fullName == null || fullName.trim().isEmpty) {
        return '';
      }
      final name = fullName.trim();
      final parts = name.split('/');
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        return parts[1].trim();
      }
      final words = name.split(' ').where((w) => w.isNotEmpty).toList();
      if (words.length > 1) {
        return words.last;
      }
      return ''; // No surname found
    } catch (e, s) {
      developer.log(
        'Error extracting surname from \'$fullName\'',
        name: 'FamilyRelationsScreen',
        error: e,
        stackTrace: s,
      );
      return ''; // Return empty on error
    }
  }

  Widget _buildFamilyNode(BuildContext context, GedcomParser parser, Map<String, dynamic> fam) {
    try {
      final familyName = fam['name'] as String? ?? 'Família ${fam['id']}';
      final isCurrentFamily = fam['id'] == family['id'];

      final parentFamilies = _getParentFamiliesFor(parser, fam);
      final childFamilies = _getChildFamiliesFor(parser, fam);

      final husbandId = (fam['husbs'] as List<String>?)?.firstOrNull;
      final wifeId = (fam['wifes'] as List<String>?)?.firstOrNull;

      final husband = husbandId != null ? parser.individuals[husbandId] : null;
      final wife = wifeId != null ? parser.individuals[wifeId] : null;

      final husbandSurname = _getSurname(husband?['name'] as String?);
      final wifeSurname = _getSurname(wife?['name'] as String?);

      return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FamilyDetailScreen(family: fam),
              ),
            );
          },
          child: Card(
            elevation: isCurrentFamily ? 8 : 4,
            color: isCurrentFamily
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isCurrentFamily
                  ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      parentFamilies.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.arrow_upward),
                              onPressed: () {
                                final targetFamily = parentFamilies.first;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FamilyRelationsScreen(
                                      family: targetFamily,
                                    ),
                                  ),
                                );
                              },
                            )
                          : const SizedBox(width: 48),
                      childFamilies.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.arrow_downward),
                              onPressed: () {
                                final targetFamily = childFamilies.first;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FamilyRelationsScreen(
                                      family: targetFamily,
                                    ),
                                  ),
                                );
                              },
                            )
                          : const SizedBox(width: 48),
                    ],
                  ),
                  if (husbandSurname.isNotEmpty || wifeSurname.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (husbandSurname.isNotEmpty)
                            HeraldicShieldWidget(surname: husbandSurname, size: 60),
                          if (husbandSurname.isNotEmpty && wifeSurname.isNotEmpty)
                            const SizedBox(width: 12),
                          if (wifeSurname.isNotEmpty)
                            HeraldicShieldWidget(surname: wifeSurname, size: 60),
                        ],
                      ),
                    ),
                  Text(
                    familyName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isCurrentFamily ? FontWeight.bold : FontWeight.normal,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ));
    } catch (e, s) {
      developer.log(
        'Error building family node for ID: ${fam['id']}',
        name: 'FamilyRelationsScreen',
        error: e,
        stackTrace: s,
      );
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          border: Border.all(color: Colors.red.shade700),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Error\nID: ${fam['id']}',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red.shade900, fontSize: 10),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getParentFamiliesFor(GedcomParser parser, Map<String, dynamic> fam) {
    final husbandId = (fam['husbs'] as List<String>?)?.firstOrNull;
    final wifeId = (fam['wifes'] as List<String>?)?.firstOrNull;

    final parentFamilies = <Map<String, dynamic>>{};

    if (husbandId != null) {
      final husband = parser.individuals[husbandId];
      final husbandFamcId = husband?['famc'] as String?;
      if (husbandFamcId != null) {
        final parentFam = parser.families
            .firstWhere((f) => f['id'] == husbandFamcId, orElse: () => {});
        if (parentFam.isNotEmpty) {
          parentFamilies.add(parentFam);
        }
      }
    }

    if (wifeId != null) {
      final wife = parser.individuals[wifeId];
      final wifeFamcId = wife?['famc'] as String?;
      if (wifeFamcId != null) {
        final parentFam = parser.families
            .firstWhere((f) => f['id'] == wifeFamcId, orElse: () => {});
        if (parentFam.isNotEmpty) {
          if (!parentFamilies.any((f) => f['id'] == wifeFamcId)) {
            parentFamilies.add(parentFam);
          }
        }
      }
    }

    return parentFamilies.toList();
  }

  List<Map<String, dynamic>> _getChildFamiliesFor(GedcomParser parser, Map<String, dynamic> fam) {
    final childIds = fam['chils'] as List<String>? ?? [];
    final childFamilies = <String, Map<String, dynamic>>{};

    for (var childId in childIds) {
      final child = parser.individuals[childId];
      final childFamsIds = child?['fams'] as List<String>? ?? [];
      for (var famsId in childFamsIds) {
        if (childFamilies.containsKey(famsId)) continue;
        final childFam =
            parser.families.firstWhere((f) => f['id'] == famsId, orElse: () => {});
        if (childFam.isNotEmpty) {
          childFamilies[famsId] = childFam;
        }
      }
    }

    return childFamilies.values.toList();
  }
}
