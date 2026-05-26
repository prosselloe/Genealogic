import 'package:flutter/material.dart';
import 'package:genealogic_balear/models/person.dart';
import 'package:genealogic_balear/providers/gedcom_provider.dart';
import 'package:genealogic_balear/screens/family_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'fullscreen_image_viewer.dart';

class PersonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> person;

  const PersonDetailScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final personData = Person.fromMap(person);
    final gedcomProvider = Provider.of<GedcomProvider>(context, listen: false);

    final familiesAsSpouse = gedcomProvider.parser!.families.where((family) {
      return (family['husbs'] as List<dynamic>? ?? []).contains(personData.id) || 
             (family['wifes'] as List<dynamic>? ?? []).contains(personData.id);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(personData.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildVitalsSection(context, personData, familiesAsSpouse),
          if (familiesAsSpouse.isNotEmpty) _buildDescendantsSection(context, familiesAsSpouse),
          if (personData.photos.isNotEmpty) _buildPhotosSection(context, personData),
          if (personData.notes.isNotEmpty) _buildNotesSection(context, personData),
          if (personData.photos.any((p) => p.note != null && p.note!.isNotEmpty))
             _buildPhotoNotesSection(context, personData), 
        ],
      ),
    );
  }

  Widget _buildVitalsSection(BuildContext context, Person personData, List<Map<String, dynamic>> familiesAsSpouse) {
    final gedcomProvider = Provider.of<GedcomProvider>(context, listen: false);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informació vital', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20, thickness: 1),
            if (personData.sex != null) ListTile(leading: const Icon(Icons.person_outline), title: Text('Sexe: ${personData.sex}')),
            if (personData.birthDate != null || personData.birthPlace != null)
              ListTile(
                leading: const Icon(Icons.cake_outlined),
                title: const Text('Naixement'),
                subtitle: Text('${personData.birthDate ?? 'Data desconeguda'}\n${personData.birthPlace ?? 'Lloc desconegut'}'),
              ),
            for (var family in familiesAsSpouse)
              _buildMarriageInfo(context, personData, family),
            if (personData.deathDate != null || personData.deathPlace != null || personData.age != null)
              ListTile(
                leading: const Icon(Icons.bedtime_outlined),
                title: const Text('Defunció'),
                subtitle: Text('${personData.deathDate ?? 'Data desconeguda'}\n${personData.deathPlace ?? 'Lloc desconegut'}${personData.age != null ? ' (Edat: ${personData.age})' : ''}'),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    final family = familiesAsSpouse.isNotEmpty
                        ? familiesAsSpouse.first
                        : (personData.famc != null
                            ? gedcomProvider.parser!.families
                                .firstWhere((f) => f['id'] == personData.famc, orElse: () => {})
                            : null);
                    if (family != null && family.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FamilyDetailScreen(family: family),
                        ),
                      );
                    }
                  },
                  child: const Text('Veure a l\'arbre'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarriageInfo(BuildContext context, Person personData, Map<String, dynamic> family) {
    final gedcomProvider = Provider.of<GedcomProvider>(context, listen: false);
    final spouseIds = (family['husbs'] as List<dynamic>? ?? []).contains(personData.id)
        ? (family['wifes'] as List<dynamic>? ?? [])
        : (family['husbs'] as List<dynamic>? ?? []);

    if (spouseIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final spouseId = spouseIds.first;
    final spouse = Person.fromMap(gedcomProvider.parser!.individuals[spouseId]!);

    return ListTile(
      leading: const Icon(Icons.favorite_border),
      title: Text('Matrimoni amb ${spouse.name}'),
      subtitle: Text('${family['marr']?['date'] ?? 'Data desconeguda'}\n${family['marr']?['plac'] ?? 'Lloc desconegut'}'),
    );
  }

  Widget _buildDescendantsSection(BuildContext context, List<Map<String, dynamic>> families) {
  final gedcomProvider = Provider.of<GedcomProvider>(context, listen: false);
  final allChildren = families
      .expand((family) => (family['chils'] as List<dynamic>? ?? []))
      .map((childId) => Person.fromMap(gedcomProvider.parser!.individuals[childId]!))
      .toList();

  if (allChildren.isEmpty) {
    return const SizedBox.shrink();
  }

  return Card(
    elevation: 4,
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Descendència', style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 20, thickness: 1),
          ...allChildren.map((child) {
            return ListTile(
              title: Text(child.name),
              subtitle: Text(
                  'Naixement: ${child.birthDate ?? 'Data desconeguda'}\nLloc: ${child.birthPlace ?? 'Lloc desconegut'}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonDetailScreen(
                      person: gedcomProvider.parser!.individuals[child.id]!,
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    ),
  );
}


  Widget _buildPhotosSection(BuildContext context, Person personData) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fotografies', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20, thickness: 1),
            SizedBox(
              height: 150, // Increased height to accommodate title
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: personData.photos.length,
                itemBuilder: (context, index) {
                  final photo = personData.photos[index];
                  return FutureBuilder<String>(
                    future: photo.effectiveUrl,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Icon(Icons.error);
                      }
                      final imageUrl = snapshot.data!;
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageViewer(photo: photo),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SizedBox(
                            width: 120,
                            child: Column(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: imageUrl.startsWith('assets/')
                                      ? Image.asset(imageUrl, fit: BoxFit.cover)
                                      : Image.network(imageUrl,
                                          fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.error)),
                                ),
                                if (photo.title != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      photo.title!,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, Person personData) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notes', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20, thickness: 1),
            ...personData.notes.map((note) => _buildNoteWidget(context, note)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteWidget(BuildContext context, String note) {
    final linkRegex = RegExp(r'Web content link:.*?<LinkURL>(.*?)</LinkURL>(?:<LinkName>(.*?)</LinkName>)?');
    final match = linkRegex.firstMatch(note);

    if (match != null) {
      final url = match.group(1)?.trim();
      if (url != null && url.isNotEmpty) {
        return InkWell(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Web content link',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      }
    }

    final cleanedNote = note.replaceFirst(RegExp(r'^\d+\s+NOTE\s+'), '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(cleanedNote, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _buildPhotoNotesSection(BuildContext context, Person personData) {
    final photosWithNotes = personData.photos.where((p) => p.note != null && p.note!.isNotEmpty);
    
    if (photosWithNotes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notes de les Fotografies', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20, thickness: 1),
            ...photosWithNotes.map((photo) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (photo.title != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          photo.title!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    Text(
                      photo.note!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}