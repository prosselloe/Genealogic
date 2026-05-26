import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:genealogic_balear/gedcom_transformer.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _fileName;
  String? _gedcomContent;
  bool _isLoading = false;
  String? _errorMessage;
  final GedcomTransformer _transformer = GedcomTransformer();

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      // Rebuild to enable/disable the convert button based on text input
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _resetState() {
    setState(() {
      _textController.clear();
      _fileName = null;
      _gedcomContent = null;
      _isLoading = false;
      _errorMessage = null;
    });
  }

  Future<void> _loadFromAssets() async {
    _resetState();
    setState(() => _isLoading = true);
    try {
      final byteData = await rootBundle.load('assets/data/1651-1704-A.txt');
      setState(() {
        _textController.text = utf8.decode(byteData.buffer.asUint8List());
        _fileName = '1651-1704-A.txt';
      });
    } catch (e, s) {
      developer.log('Error loading asset', error: e, stackTrace: s, name: 'ConverterScreen');
      setState(() => _errorMessage = 'No s\'ha pogut carregar el fitxer de mostra: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFromFilePicker() async {
    _resetState();
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result == null) {
        setState(() => _isLoading = false);
        return; // User canceled the picker
      }

      final fileBytes = result.files.single.bytes;
      if (fileBytes == null) {
        throw Exception("No s'ha pogut llegir el contingut del fitxer.");
      }

      setState(() {
        _textController.text = utf8.decode(fileBytes);
        _fileName = result.files.single.name;
      });
    } catch (e, s) {
      developer.log('Error loading file', error: e, stackTrace: s, name: 'ConverterScreen');
      setState(() => _errorMessage = 'Error en carregar el fitxer: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _convertToGedcom() async {
    if (_textController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _gedcomContent = null;
    });
    try {
      final result = await _transformer.transform(_textController.text);
      setState(() {
        _gedcomContent = result;
      });
    } catch (e, s) {
      developer.log('Error converting to GEDCOM', error: e, stackTrace: s, name: 'ConverterScreen');
      setState(() {
        _errorMessage = 'Error durant la conversió a GEDCOM: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _downloadGedcom() {
    if (_gedcomContent == null || !kIsWeb) return;

    final baseName = _fileName?.split('.').first ?? 'generated';
    final downloadFileName = '$baseName.ged';

    final bytes = utf8.encode(_gedcomContent!);
    final blob = html.Blob([bytes], 'text/plain', 'native');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', downloadFileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor a GEDCOM'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildInputCard(),
                const SizedBox(height: 16),
                _buildActionsCard(),
                if (_errorMessage != null) _buildErrorCard(),
                if (_gedcomContent != null)
                  _buildContentCard('Resultat en Format GEDCOM', _gedcomContent!),
              ],
            ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _fileName != null ? 'Contingut de: $_fileName' : 'Enganxa aquí les teves dades',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8.0),
                color: Theme.of(context).colorScheme.surface.withAlpha(128),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _textController,
                    maxLines: null, // Allows for multiline input
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Pots enganxar text directament o carregar un fitxer...',
                    ),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 4.0,
      color: Theme.of(context).colorScheme.errorContainer,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer, size: 32),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    final canConvert = _textController.text.isNotEmpty;
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.file_upload_outlined),
              onPressed: _loadFromFilePicker,
              label: const Text('Carregar Fitxer'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.article_outlined),
              onPressed: _loadFromAssets,
              label: const Text('Carregar Mostra'),
            ),
            if (canConvert)
              FilledButton.icon(
                icon: const Icon(Icons.transform),
                onPressed: _convertToGedcom,
                label: const Text('Convertir a GEDCOM'),
              ),
            if (_gedcomContent != null && kIsWeb)
              FilledButton.icon(
                icon: const Icon(Icons.download),
                onPressed: _downloadGedcom,
                label: const Text('Descarregar .ged'),
              ),
            if (canConvert || _gedcomContent != null)
              TextButton.icon(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _resetState,
                label: const Text('Netejar', style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(String title, String content) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(top: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8.0),
                color: Theme.of(context).colorScheme.surface.withAlpha(128),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: SelectableText(
                    content,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
