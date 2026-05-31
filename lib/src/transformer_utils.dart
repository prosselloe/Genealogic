import 'package:intl/intl.dart';

class NameInfo {
  final String givenName;
  final String surname;
  final String? secondarySurname;
  NameInfo(this.givenName, this.surname, {this.secondarySurname});
}

class ParentInfo {
  final String fatherName;
  final String motherName;
  final String motherSurname;
  ParentInfo(this.fatherName, this.motherName, this.motherSurname);
}

class TestamentInfo {
  final String date;
  final String rawText;
  TestamentInfo(this.date, this.rawText);
}

// --- Robust Data Extraction Functions ---

/// Extracts the primary name and surname from a line like "Abraham, Francesc".
/// Returns a tuple with (givenName, surname).
(String, String) extractPatriarchName(String line) {
  final parts = line.split(',');
  if (parts.length < 2) return ('', line.trim());
  final surname = parts[0].trim();
  final givenName = parts[1].split('(').first.trim();
  return (givenName, surname);
}


NameInfo extractNameInfo(String text) {
    // Clean the text by removing dates, ages and extra notes in parentheses
    String cleanedText = text
        .replaceAll(RegExp(r'\s*\(\d{1,2}-\d{1,2}-\d{4}\)'), '') // (dd-mm-yyyy)
        .replaceAll(RegExp(r'\s*\(\d+\)'), '') // (age)
        .replaceAll(RegExp(r'\(N\)'), '')
        .trim();

    final nameParts = cleanedText.split(' ');
    if (nameParts.length > 1) {
        final surname = nameParts.removeLast();
        final givenName = nameParts.join(' ');
        return NameInfo(givenName, surname);
    }
    return NameInfo(cleanedText, ''); // Fallback
}


/// Extracts parent information using a robust regex.
ParentInfo? extractParentInfo(String text) {
  // Regex to capture father's name, mother's name, and mother's surname.
  // It looks for "de <father> i de <mother> <mother_surname>"
  final match = RegExp(r"de\s+(.+?)\s+i\s+de\s+(.+?)\s+([\wÀ-ú]+)(?=\s*\(|$)").firstMatch(text);
  if (match != null) {
    final fatherName = match.group(1)!.trim();
    final motherName = match.group(2)!.trim();
    final motherSurname = match.group(3)!.trim();
    return ParentInfo(fatherName, motherName, motherSurname);
  }
  return null;
}

/// Parses a date from various possible formats.
String? parseDate(String? dateString) {
  if (dateString == null) return null;
  dateString = dateString.replaceAll(',', '-').replaceAll(' ', '').trim();
  
  // Handle (N) case
  if (dateString.toUpperCase() == '(N)') return 'Date unknown';

  try {
    // Format: dd-mm-yyyy
    return DateFormat('dd MMM yyyy', 'ca').format(DateFormat('d-M-y').parse(dateString)).toUpperCase();
  } catch (e) {
    try {
      // Format: yyyy-d-m
       final parts = dateString.split('-');
       if(parts.length == 3) {
          return DateFormat('dd MMM yyyy', 'ca').format(DateFormat('y-d-M').parse(dateString)).toUpperCase();
       }
    } catch(e) {
      // Fallback for just year or other formats
      return dateString.replaceAll('-', ' ');
    }
  }
   return dateString.replaceAll('-', ' ');
}

/// Extracts the first valid date found in a string.
String? extractDate(String text) {
  // Regex for dd-mm-yyyy or yyyy, d-m
  final match = RegExp(r'(\d{1,2}-\d{1,2}-\d{4})|(\d{4},\s*\d{1,2}-\d{1,2})|\(N\)').firstMatch(text);
  if (match != null) {
    return parseDate(match.group(0));
  }
  return null;
}

String? extractDeathDate(String text) {
  var match = RegExp(r'\+\s*([\d-]+|\d{4},\s*\d{1,2}-\d{1,2})').firstMatch(text);
  if (match != null) {
    return parseDate(match.group(1));
  }
  return null;
}


int? extractAge(String text) {
  final match = RegExp(r'\((\d+)\)').firstMatch(text);
  return match != null ? int.tryParse(match.group(1)!) : null;
}


TestamentInfo? extractTestamentInfo(String text) {
  final match = RegExp(r'T\.\s*([\d,-]+)\s*\(([^)]+)\)').firstMatch(text);
  if (match != null) {
    final date = parseDate(match.group(1)!) ?? match.group(1)!;
    final rawText = match.group(0)!;
    return TestamentInfo(date, rawText);
  }
  return null;
}

String extractAllNotes(String line) {
    // This is a placeholder. A robust implementation would remove known structured data
    // and return the rest. For now, we focus on specific notes.
    
    // Extract profession, e.g. (picapedrer)
    final professionMatch = RegExp(r'\((picapedrer|fuster)\)').firstMatch(line);
    if(professionMatch != null) {
        return professionMatch.group(1)!;
    }
    
    // Extract notes after '+' sign
    final deathNotesMatch = RegExp(r'\+\s*.*?\s*\((.*?)\)').firstMatch(line);
    if(deathNotesMatch != null){
        return deathNotesMatch.group(1)!;
    }

    // Extract notes from testament
    final testamentNotesMatch = RegExp(r'T\..*?\)(.*)').firstMatch(line);
    if(testamentNotesMatch != null && testamentNotesMatch.group(1)!.trim().isNotEmpty){
        return testamentNotesMatch.group(1)!.trim();
    }
    
    return ''; // Return empty if no specific notes found
}

String inferSex(String name) {
  final lowerCaseName = name.toLowerCase();
  // Simplified list, can be expanded
  final femaleNames = ['a', 'na', 'ia', 'ina', 'ada', 'una'];
  if (femaleNames.any((suffix) => lowerCaseName.endsWith(suffix))) {
    // Specific overrides
    if (lowerCaseName == 'joan') return 'M';
    if (lowerCaseName == 'sebastià') return 'M';
    return 'F';
  }
  return 'M';
}