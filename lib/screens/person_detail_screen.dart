import 'package:flutter/material.dart';
import 'package:genealogic/models/person.dart';
import 'package:genealogic/providers/gedcom_provider.dart';
import 'package:provider/provider.dart';
import 'fullscreen_image_viewer.dart';

class PersonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> person;

  const PersonDetailScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final personData = Person.fromMap(person);
    final gedcomProvider = Provider.of<GedcomProvider>(context, listen: false);

    final familiesAsSpouse = gedcomProvider.parser!.families.where((family) {
      return (family['husbs'] as List<String>? ?? []).contains(personData.id) || 
             (family['wifes'] as List<String>? ?? []).contains(personData.id);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(personData.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildVitalsSection(context, personData, familiesAsSpouse),
          if (personData.photos.isNotEmpty) _buildPhotosSection(context, personData),
          if (personData.notes.isNotEmpty) _buildNotesSection(context, personData),
        ],
      ),
    );
  }

  Widget _buildVitalsSection(BuildContext context, Person personData, List<Map<String, dynamic>> familiesAsSpouse) {
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
              if (family['marr']?['date'] != null || family['marr']?['plac'] != null)
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Matrimoni'),
                  subtitle: Text('${family['marr']?['date'] ?? 'Data desconeguda'}\n${family['marr']?['plac'] ?? 'Lloc desconegut'}'),
                ),
            if (personData.deathDate != null || personData.deathPlace != null || personData.age != null)
              ListTile(
                leading: const Icon(Icons.bedtime_outlined),
                title: const Text('Defunció'),
                subtitle: Text('${personData.deathDate ?? 'Data desconeguda'}\n${personData.deathPlace ?? 'Lloc desconegut'}${personData.age != null ? ' (Edat: ${personData.age})' : ''}'),
              ),
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
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: personData.photos.length,
                itemBuilder: (context, index) {
                  final photo = personData.photos[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(imageUrl: photo.url),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(photo.url, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.error)),
                      ),
                    ),
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
            ...personData.notes.map((note) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(note, style: Theme.of(context).textTheme.bodyMedium),
            )),
          ],
        ),
      ),
    );
  }
}
