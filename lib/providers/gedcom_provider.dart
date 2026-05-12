import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:genealogic/gedcom_parser.dart';

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
        _status = GedcomStatus.loaded;
      }
    } catch (e) {
      _error = 'Error loading file: $e';
      _status = GedcomStatus.error;
    }
    notifyListeners();
  }

  String _decodeGedcom(Uint8List bytes) {
    try {
      // First, try to decode as UTF-8, as it's the standard.
      return utf8.decode(bytes, allowMalformed: false); // Strict
    } on FormatException {
      // If it fails, it's likely mislabeled and is actually latin1.
      // This is a common issue with GEDCOM files.
      return latin1.decode(bytes);
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
