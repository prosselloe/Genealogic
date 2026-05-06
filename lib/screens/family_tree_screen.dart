import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../gedcom_parser.dart';

class FamilyTreeScreen extends StatefulWidget {
  final GedcomParser parser;

  const FamilyTreeScreen({super.key, required this.parser});

  @override
  FamilyTreeScreenState createState() => FamilyTreeScreenState();
}

class FamilyTreeScreenState extends State<FamilyTreeScreen> {
  Graph _graph = Graph();
  Algorithm? _algorithm;
  bool _isGraphBuilt = false;

  @override
  void initState() {
    super.initState();
    developer.log('initState: Starting FamilyTreeScreen.', name: 'FamilyTreeScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log('addPostFrameCallback: Starting graph building.', name: 'FamilyTreeScreen');
      _buildFullGraph();
      if (mounted) {
        setState(() {
          _isGraphBuilt = true;
          developer.log('addPostFrameCallback: setState finished, graph built.', name: 'FamilyTreeScreen');
        });
      }
    });
  }

  void _buildFullGraph() {
    developer.log('buildFullGraph: Starting with corrected parser data.', name: 'FamilyTreeScreen');
    final newGraph = Graph();
    final nodes = <String, Node>{};

    if (widget.parser.individuals.isEmpty) {
        developer.log('No individuals found to build a graph.', name: 'FamilyTreeScreen');
        setState(() { _graph = newGraph; });
        return;
    }

    widget.parser.individuals.forEach((id, individual) {
      nodes[id] = Node.Id(id);
      newGraph.addNode(nodes[id]!);
    });

    for (var fam in widget.parser.families) {
      final familyId = fam['id'] as String;

      final husbandId = fam['husb'] as String?;
      final wifeId = fam['wife'] as String?;
      final childrenData = fam['chil'];
      final children = (childrenData is List ? childrenData.cast<String>() : [if (childrenData is String) childrenData]).toList();

      final hasConnections =
          (husbandId != null && nodes.containsKey(husbandId)) ||
          (wifeId != null && nodes.containsKey(wifeId)) ||
          children.any((childId) => nodes.containsKey(childId));

      if (hasConnections) {
        final familyNode = Node.Id(familyId);
        newGraph.addNode(familyNode);

        if (husbandId != null && nodes.containsKey(husbandId)) {
          newGraph.addEdge(nodes[husbandId]!, familyNode, paint: Paint()..color = Colors.transparent);
        }
        if (wifeId != null && nodes.containsKey(wifeId)) {
          newGraph.addEdge(nodes[wifeId]!, familyNode, paint: Paint()..color = Colors.transparent);
        }

        for (var childId in children) {
          if (nodes.containsKey(childId)) {
            newGraph.addEdge(familyNode, nodes[childId]!);
          }
        }
      }
    }

    final builder = SugiyamaConfiguration();
    builder.nodeSeparation = 150;
    builder.levelSeparation = 150;
    builder.orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;
    _algorithm = SugiyamaAlgorithm(builder);

    _graph = newGraph;

    developer.log('buildFullGraph: Finished. Nodes: ${_graph.nodeCount()}, Edges: ${_graph.edges.length}.', name: 'FamilyTreeScreen');
  }


  void _showDetailsDialog(Map<String, dynamic> individual) {
    final name = individual['name'] as String? ?? 'Unknown';
    final photoUrl = individual['photo'] as String?;
    final birth = individual['BIRT'] as Map<String, dynamic>?;
    final death = individual['DEAT'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          title: Row(
            children: [
              if (photoUrl != null && Uri.tryParse(photoUrl)?.isAbsolute == true)
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 16),
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
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: Icon(Icons.person, size: 40, color: Colors.grey[600]),
                ),
              Expanded(
                child: Text(name, style: Theme.of(context).textTheme.titleLarge),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                if (birth != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Born: ${birth['date'] ?? ''} in ${birth['plac'] ?? ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                if (death != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Died: ${death['date'] ?? ''} in ${death['plac'] ?? ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    developer.log('build: Building widget. isGraphBuilt: $_isGraphBuilt', name: 'FamilyTreeScreen');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Tree'),
      ),
      body: !_isGraphBuilt || _algorithm == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Building Tree...'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(200),
                    minScale: 0.01,
                    maxScale: 2.0,
                    child: GraphView(
                      graph: _graph,
                      algorithm: _algorithm!,
                      paint: Paint()
                        ..color = Theme.of(context).colorScheme.secondary
                        ..strokeWidth = 1.5
                        ..style = PaintingStyle.stroke,
                      builder: (Node node) {
                        final id = node.key!.value as String;
                        if (id.startsWith('@F')) {
                          return Container(
                            width: 1,
                            height: 1,
                            decoration: const BoxDecoration(color: Colors.transparent),
                          );
                        }
                        return _buildPersonNodeWidget(id);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPersonNodeWidget(String id) {
    final individual = widget.parser.individuals[id];
    if (individual == null) {
      return const SizedBox.shrink();
    }

    final name = individual['name'] as String? ?? 'Unknown';
    final photoUrl = individual['photo'] as String?;

    return GestureDetector(
      onTap: () {
        _showDetailsDialog(individual);
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
              name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
