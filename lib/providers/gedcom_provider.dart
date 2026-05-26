import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:genealogic_balear/gedcom_parser.dart';

enum GedcomStatus { initial, loading, loaded, error }

class GedcomProvider with ChangeNotifier {
  GedcomParser? _parser;
  List<String> _surnames = [];
  GedcomStatus _status = GedcomStatus.initial;
  String? _error;

  GedcomParser? get parser => _parser;
  List<String> get surnames => _surnames;
  GedcomStatus get status => _status;
  String? get error => _error;

  GedcomProvider() {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _status = GedcomStatus.loading;
    notifyListeners();
    try {
      final byteData = await rootBundle.load('assets/data/myheritage.ged');
      final data = _decodeGedcom(byteData.buffer.asUint8List());
      _parser = GedcomParser();
      await _parser!.parse(data);
      _updateSurnames();
      _status = GedcomStatus.loaded;
    } catch (e) {
      _error = 'Error loading initial data: $e';
      _status = GedcomStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadGedcomFromFile() async {
    _status = GedcomStatus.loading;
    notifyListeners();
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ged'],
        withData: true,
      );

      if (result != null) {
        Uint8List fileBytes;
        if (kIsWeb) {
          if (result.files.single.bytes == null) {
            throw Exception("File bytes are null on web.");
          }
          fileBytes = result.files.single.bytes!;
        } else {
          if (result.files.single.path == null) {
            throw Exception("File path is null on native.");
          }
          final file = File(result.files.single.path!);
          fileBytes = await file.readAsBytes();
        }

        final data = _decodeGedcom(fileBytes);
        
        _parser = GedcomParser();
        await _parser!.parse(data);
        _updateSurnames();
        _status = GedcomStatus.loaded;

      } else {
        _status = (_parser != null) ? GedcomStatus.loaded : GedcomStatus.initial;
      }
    } catch (e) {
      _error = 'Error loading file: $e';
      _status = GedcomStatus.error;
    }
    notifyListeners();
  }

  // Helper function to find line and column from a byte offset
  (int, int) _findLineAndColumn(Uint8List bytes, int offset) {
    int line = 1;
    int column = 1;
    for (int i = 0; i < offset; i++) {
      if (bytes[i] == 0x0A) { // ASCII value for newline '\n'
        line++;
        column = 1;
      } else {
        column++;
      }
    }
    return (line, column);
  }

  String _decodeGedcom(Uint8List bytes) {
    try {
      // First, check for the CHAR tag to confirm encoding
      final firstFewLines = utf8.decode(bytes.take(200).toList(), allowMalformed: true);
      final charLine = firstFewLines.split('\n').firstWhere(
        (line) => line.trim().startsWith('1 CHAR'),
        orElse: () => '',
      );

      if (charLine.isNotEmpty && !charLine.contains('UTF-8')) {
        throw FormatException(
          'GEDCOM file is not declared as UTF-8. Found: "$charLine". Please save the file with UTF-8 encoding.'
        );
      }

      // Enforce strict UTF-8 decoding
      return utf8.decode(bytes, allowMalformed: false);
    } on FormatException catch (e) {
      final (line, column) = _findLineAndColumn(bytes, e.offset ?? 0);
      throw FormatException(
        'Invalid UTF-8 character found at line $line, column $column. The file must be saved with UTF-8 encoding.',
        e.source,
        e.offset,
      );
    } catch (e) {
      // Rethrow other potential errors
      rethrow;
    }
  }

  void _updateSurnames() {
    if (_parser == null) return;
    final surnames = <String>{};
    for (var family in _parser!.families) {
      final familyName = family['name'] as String?;
      if (familyName != null && familyName.contains(' - ')) {
        final parts = familyName.split(' - ');
        if (parts.length == 2) {
          final firstSurname = parts[0].trim();
          final secondSurname = parts[1].trim();
          if (firstSurname.isNotEmpty) {
            surnames.add(firstSurname);
          }
          if (secondSurname.isNotEmpty) {
            surnames.add(secondSurname);
          }
        }
      }
    }
    final sortedSurnames = surnames.toList()..sort();
    _surnames = ['Tots', ...sortedSurnames];
  }
}