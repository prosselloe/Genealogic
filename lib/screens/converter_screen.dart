import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:genealogic_balear/gedcom_transformer.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_selector/file_selector.dart';

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
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _resetState() {
    setState(() {
      _textController.clear();
      _fileName = null;
      _gedcomContent = null;
      _errorMessage = null;
    });
  }

  Future<void> _loadFromAssets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? loadedContent;
    String? error;

    try {
      loadedContent = await rootBundle.loadString('assets/data/1651-1704-A.txt');
    } catch (e, s) {
      developer.log('Error loading asset', error: e, stackTrace: s, name: 'ConverterScreen');
      error = 'No s\'ha pogut carregar el fitxer de mostra: $e';
    }

    setState(() {
      _isLoading = false;
      _errorMessage = error;
      _gedcomContent = null;

      if (loadedContent != null) {
        _textController.text = loadedContent;
        _fileName = '1651-1704-A.txt';
      } else {
        _textController.clear();
        _fileName = null;
      }
    });
  }

  Future<void> _loadFromFilePicker() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? loadedContent;
    String? loadedFileName;
    String? error;

    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
      );
      final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

      if (file != null) {
        loadedFileName = file.name;
        loadedContent = await file.readAsString();
      } else {
        setState(() => _isLoading = false);
        return;
      }
    } catch (e, s) {
      developer.log('Error loading file', error: e, stackTrace: s, name: 'ConverterScreen');
      error = 'Error en carregar el fitxer: $e';
    }

    setState(() {
      _isLoading = false;
      _errorMessage = error;
      _gedcomContent = null;

      if (loadedContent != null) {
        _textController.text = loadedContent;
        _fileName = loadedFileName;
      } else {
        _textController.clear();
        _fileName = null;
      }
    });
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
        _errorMessage = 'Error durant la conversió a GEDCOM: $e\nAssegura\'t que el format del text és correcte.';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionButtons(),
            const SizedBox(height: 16),
            if (_errorMessage != null) _buildErrorCard(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _gedcomContent == null
                      ? _buildInputArea()
                      : _buildResultArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.file_upload_outlined),
          onPressed: _loadFromFilePicker,
          label: const Text('Carregar Fitxer...'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.article_outlined),
          onPressed: _loadFromAssets,
          label: const Text('Carregar Mostra'),
        ),
        if (_gedcomContent != null && kIsWeb)
          FilledButton.icon(
            icon: const Icon(Icons.download),
            onPressed: _downloadGedcom,
            label: const Text('Descarregar .ged'),
          ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _textController,
          builder: (context, value, child) {
            if (value.text.isNotEmpty || _gedcomContent != null) {
              return TextButton.icon(
                icon: const Icon(Icons.clear),
                onPressed: _resetState,
                label: const Text('Netejar'),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enganxa les dades o carrega un fitxer:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Les dades apareixeran aquí...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _textController,
          builder: (context, value, child) {
            return FilledButton.icon(
              icon: const Icon(Icons.transform),
              onPressed: value.text.isNotEmpty ? _convertToGedcom : null,
              label: const Text('Convertir a GEDCOM'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _fileName != null ? 'Resultat de: $_fileName' : 'Resultat de la conversió',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).colorScheme.surface.withAlpha(50),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: SelectableText(
                  _gedcomContent!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.errorContainer,
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
      ),
    );
  }
}
