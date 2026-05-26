import 'package:intl/intl.dart';

// --- General Purpose Parsers ---

String? parseDate(String? dateString) {
  if (dateString == null) return null;
  try {
    // Try to parse dd-MM-yyyy first
    final date = DateFormat('dd-MM-yyyy').parse(dateString);
    return DateFormat('dd MMM yyyy').format(date).toUpperCase();
  } catch (e) {
    // If it fails, it might be in another format or just a year
    return dateString; // Return original if parsing fails
  }
}

String? extractDate(String text) {
  // Regex to find a date in parentheses like (dd-MM-yyyy)
  final match = RegExp(r'\((\d{1,2}-\d{1,2}-\d{4})\)').firstMatch(text);
  if (match != null) {
    return parseDate(match.group(1)!);
  }
  return null;
}

/// Extracts a death date from a string based on specific patterns.
///
/// Handles formats like:
/// - `+ 27-5-1716.`
/// - `1697, 21-9 ...`
///
/// Returns a formatted date string (e.g., "27 MAY 1716") or null.
String? extractDeathDate(String text) {
  // Pattern 1: `+ 27-5-1716.`
  var match = RegExp(r'\+\s*(\d{1,2}-\d{1,2}-\d{4})').firstMatch(text);
  if (match != null) {
    return parseDate(match.group(1)!);
  }

  // Pattern 2: `1697, 21-9 ...`
  match = RegExp(r'(\d{4}),\s*(\d{1,2}-\d{1,2})').firstMatch(text);
  if (match != null) {
    final year = match.group(1)!;
    final dayMonth = match.group(2)!;
    return parseDate('$dayMonth-$year');
  }

  return null;
}


String inferSex(String name) {
  final lowerCaseName = name.toLowerCase();
  // Add more robust rules based on common names if needed
  if (lowerCaseName.endsWith('a') ||
      lowerCaseName.endsWith('na') ||
      lowerCaseName == 'caterina' ||
      lowerCaseName == 'margarita' ||
      lowerCaseName == 'coloma') {
    return 'F';
  }
  return 'M'; // Default to Male if unsure
}

int? extractAge(String text) {
  final match = RegExp(r'\((\d+)\)').firstMatch(text);
  return match != null ? int.parse(match.group(1)!) : null;
}

// --- Specific Line Parsers ---

class TestamentInfo {
  final String date;
  final String rawText;
  TestamentInfo(this.date, this.rawText);
}

TestamentInfo? extractTestamentNotes(String text) {
  final match = RegExp(r'T\.\s+([\d-]+(?:, \d+-\d+)?),?\s*(.*)').firstMatch(text);
  if (match != null) {
    final date = parseDate(match.group(1)!) ?? match.group(1)!;
    final fullNote = match.group(0)!; // Capture the whole matched string as raw text
    return TestamentInfo(date, fullNote);
  }
  return null;
}

class ParentInfo {
  final String fatherName, motherName, motherSurname;
  ParentInfo(this.fatherName, this.motherName, this.motherSurname);
}

ParentInfo? extractParentage(String text, String childGivenName, String childSurname) {
  // Remove age in parentheses, e.g., (30)
  final cleanedText = text.replaceAll(RegExp(r'\s*\(\d+\)\s*'), ' ').trim();

  // Split by " i de "
  final parts = cleanedText.split(' i de ');
  if (parts.length == 2) {
    // Father's name is in the first part, after "de "
    final fatherName = parts[0].replaceFirst('de ', '').trim();

    // Mother's info is in the second part. It might have notes at the end.
    final motherText = parts[1];
    // Take everything before the first comma as the mother's full name
    final motherFullName = motherText.split(',')[0].trim();
    final motherNameParts = motherFullName.split(' ');

    if (motherNameParts.isNotEmpty) {
      final motherSurname = motherNameParts.removeLast();
      final motherName = motherNameParts.join(' ');
      return ParentInfo(fatherName, motherName, motherSurname);
    }
  }
  return null;
}


// --- Child Line Specific Parsers ---

String extractChildName(String childLine) {
  // Find the first occurrence of '(', '.', or '+'
  final terminators = ['(', '.', '+'];
  int endIndex = -1;

  for (final terminator in terminators) {
    final index = childLine.indexOf(terminator);
    if (index != -1) {
      if (endIndex == -1 || index < endIndex) {
        endIndex = index;
      }
    }
  }
  
  // Handle the case '1697, 21-9...' where a death date follows the name
  final deathMatch = RegExp(r',\s*\d{1,2}-\d{1,2}').firstMatch(childLine);
  if (deathMatch != null) {
      final index = deathMatch.start;
       if (endIndex == -1 || index < endIndex) {
        endIndex = index;
      }
  }


  if (endIndex != -1) {
    // If the name is just a year, it's probably part of a death date, not a name
    final potentialName = childLine.substring(0, endIndex).trim();
    if (RegExp(r'^\d{4}$').hasMatch(potentialName)) {
        return childLine.trim(); // The line might just be a name with no other info
    }
    return potentialName;
  }
  
  // If no terminators are found, the whole line is the name
  return childLine.trim();
}


String? extractChildNotes(String childLine, String childName) {
  // Remove the name first
  String note = childLine.replaceFirst(childName, '');

  // Remove the birth date part, e.g., (8-7-1666)
  final dateRegex = RegExp(r'\(\s*\d{1,2}-\d{1,2}-\d{4}\s*\)');
  note = note.replaceAll(dateRegex, '');

  // Remove death date part, e.g., `+ 27-5-1716.` or `1697, 21-9...`
  note = note.replaceAll(RegExp(r'\+\s*\d{1,2}-\d{1,2}-\d{4}\.?'), '');
  note = note.replaceAll(RegExp(r'\d{4},\s*\d{1,2}-\d{1,2}'), '');


  // Clean up leading/trailing separators and whitespace
  note = note.trim().replaceFirst(RegExp(r'^[.,\s]+'), '').trim();

  return note.isNotEmpty ? note : null;
}
