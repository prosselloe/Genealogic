import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genealogic/main.dart';
import 'package:genealogic/screens/family_tree_screen.dart';
import 'package:flutter/services.dart';

void main() {
  // This setup function is crucial for mocking the asset bundle
  // It allows us to inject a fake GEDCOM file for our tests.
  Future<void> setupMockAssetBundle(WidgetTester tester) async {
    // We use a local gedcomData string as our mock file content.
    const String gedcomData = '''
0 @I1@ INDI
1 NAME John /Doe/
0 @I2@ INDI
1 NAME Jane /Smith/
0 @F1@ FAM
1 HUSB @I1@
1 WIFE @I2@
''';

    // The rootBundle needs to be overridden to intercept the file loading.
    // We use a custom closure that checks for our specific asset path.
    tester.binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', 
      (ByteData? message) async {
        // The filename is encoded in the message. We decode it to check.
        final String assetKey = utf8.decode(message!.buffer.asUint8List());
        if (assetKey == 'assets/data/myheritage.ged') {
          // If it's our target file, return the mock data.
          return const StringCodec().encodeMessage(gedcomData);
        }
        // For any other asset, return null to let it handle it normally.
        return null;
      }
    );
  }

  testWidgets('Renders loading indicator and then the family list', (WidgetTester tester) async {
    await setupMockAssetBundle(tester);

    await tester.pumpWidget(const GenealogicApp());

    // Expect a loading indicator while the future is resolving
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the FutureBuilder to complete
    await tester.pumpAndSettle();

    // Now, the FamilyTreeScreen should be visible
    expect(find.byType(FamilyTreeScreen), findsOneWidget);
    expect(find.text('John /Doe/ & Jane /Smith/'), findsOneWidget);
  });

  testWidgets('Search functionality filters the family list', (WidgetTester tester) async {
    await setupMockAssetBundle(tester);
    await tester.pumpWidget(const GenealogicApp());
    await tester.pumpAndSettle();

    // Find the search field
    final searchField = find.widgetWithText(TextField, 'Search Families...');
    expect(searchField, findsOneWidget);

    // Search for a specific family
    await tester.enterText(searchField, 'Doe');
    await tester.pump();

    // Verify that only the matching family is shown
    expect(find.text('John /Doe/ & Jane /Smith/'), findsOneWidget);

    // Search for something that doesn't exist
    await tester.enterText(searchField, 'Unknown');
    await tester.pump();

    // Verify that no families are shown
    expect(find.text('John /Doe/ & Jane /Smith/'), findsNothing);
  });
}
