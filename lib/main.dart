import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:genealogic_balear/providers/gedcom_provider.dart';
import 'package:genealogic_balear/screens/family_tree_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => GedcomProvider()),
      ],
      child: const GenealogicApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

class GenealogicApp extends StatelessWidget {
  const GenealogicApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.brown;

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.lora(fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.25),
      displayMedium: GoogleFonts.lora(fontSize: 45, fontWeight: FontWeight.bold, letterSpacing: 0.0),
      displaySmall: GoogleFonts.lora(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 0.0),
      headlineLarge: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 0.0),
      headlineMedium: GoogleFonts.lora(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.0),
      headlineSmall: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 0.0),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0.15),
      titleMedium: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      titleSmall: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
      bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0.25),
      bodySmall: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0.4),
      labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
      labelMedium: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.0),
      labelSmall: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
        primary: const Color(0xFF5D4037), // brown-700
        secondary: const Color(0xFF795548), // brown-500
        surface: const Color(0xFFF5F5F5), // grey-100
      ),
      scaffoldBackgroundColor: const Color(0xFFEFEBE9), // brown-50
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF4E342E), // brown-800
        foregroundColor: Colors.white,
        titleTextStyle: appTextTheme.headlineSmall?.copyWith(color: Colors.white),
        elevation: 4,
        shadowColor: Colors.black.withAlpha(26),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: const Color(0xFFFFFFFF), 
        selectedTileColor: const Color(0xFFD7CCC8), // brown-100
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF5D4037), // brown-700
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: appTextTheme.labelLarge,
        ),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
        primary: const Color(0xFF8D6E63), // brown-300
        secondary: const Color(0xFFA1887F), // brown-200
        surface: const Color(0xFF212121), // grey-900
      ),
      scaffoldBackgroundColor: const Color(0xFF1a1a1a), // darker grey
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF3E2723), // brown-900
        foregroundColor: Colors.white,
        titleTextStyle: appTextTheme.headlineSmall?.copyWith(color: Colors.white),
        elevation: 4,
        shadowColor: Colors.black.withAlpha(26),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFF2C2C2C),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: const Color(0xFF2C2C2C),
        selectedTileColor: const Color(0xFF4E342E), // brown-800
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF8D6E63), // brown-300
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: appTextTheme.labelLarge,
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Genealogic Balear',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: Consumer<GedcomProvider>(
            builder: (context, gedcomProvider, child) {
              switch (gedcomProvider.status) {
                case GedcomStatus.loading:
                case GedcomStatus.initial:
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                case GedcomStatus.error:
                  return Scaffold(
                    body: Center(child: Text('Error: ${gedcomProvider.error}')),
                  );
                case GedcomStatus.loaded:
                  return FamilyTreeScreen();
              }
            },
          ),
        );
      },
    );
  }
}
