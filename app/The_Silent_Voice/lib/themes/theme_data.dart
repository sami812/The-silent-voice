import 'package:flutter/material.dart';

/// # App Theme Data
/// `AppThemeData` defines the **light** and **dark** themes used across the app.
/// - Contains custom `TextTheme`, `CardTheme`, `ColorScheme`, `AppBarTheme`, and more.
/// - Ensures a consistent look and feel between light and dark modes.
class AppThemeData {
  /// ## Light Theme
  /// - Primary background: white
  /// - Cards: light grey with rounded corners
  /// - Text: dark colors for readability
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'OpenSans',
    /// Card Theme
    cardTheme: CardThemeData(
      color:Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:  Colors.grey[300]!,
          width: 1, 
        ),
      ),
    ),
    scaffoldBackgroundColor: Colors.white,
    /// AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor:  Colors.white,
    ),
    /// Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
    ),
    /// Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:Colors.white,
    ),
    /// Color Scheme
    colorScheme: ColorScheme.light(
      secondary:  Colors.blue[100]!,
      primaryContainer: Colors.white,
      tertiaryContainer: Colors.grey[100],
      outline: Colors.grey[300],
    ),
    /// Text Theme
    textTheme: TextTheme(
      titleMedium: TextStyle(color: Colors.black,fontSize: 26, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(
        color: Colors.black,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        fontSize: 18,
        color:Colors.grey[800],
      ),
      bodySmall: TextStyle(
        fontSize: 16,
        color:Colors.grey[800],
      ),
      displaySmall: TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.w300,
      ),
      titleLarge: TextStyle(
        color: Colors.black,
        fontSize: 20, 
        fontWeight: FontWeight.bold,
      )
    )
  );
  /// ## Dark Theme
  /// - Primary background: dark blue/black
  /// - Cards: darker grey with rounded corners
  /// - Text: white and light grey for readability
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'OpenSans',
    /// Card Theme
    cardTheme: CardThemeData(
      color: Color(0xFF1B1F34),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:  Colors.grey[800]!,
          width: 1, 
        ),
      ),
    ),
    scaffoldBackgroundColor:Color(0xFF0A0E1A),
    /// AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1B1F34),
    ),
    /// Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey[800],
      thickness: 1,
    ),
    /// Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1B1F34),
    ),
    /// Color Scheme
    colorScheme: ColorScheme.dark(
      secondary:  Color(0xFF5D688F),
      primaryContainer:  Color(0xFF1B1F34),
      tertiaryContainer:Color(0xFF1B1F34),
      outline: Colors.grey[800],
    ),
    /// Text Theme
    textTheme: TextTheme(
      titleMedium: TextStyle(color: Colors.white,fontSize: 26, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        fontSize: 18,
        color:Colors.grey[500],
      ),
      bodySmall: TextStyle(
        fontSize: 16,
        color:Colors.grey[500],
      ),
      displaySmall: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w300,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 20, 
        fontWeight: FontWeight.bold,
      )
    )
  );
}
