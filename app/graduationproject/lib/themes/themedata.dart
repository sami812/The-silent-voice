import 'package:flutter/material.dart';

class AppThemeData {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'OpenSans',
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
    appBarTheme: AppBarTheme(
      backgroundColor:  Colors.white,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:Colors.white,
    ),
    colorScheme: ColorScheme.light(
      secondary:  Colors.blue[100]!,
      primaryContainer: Colors.white,
      tertiaryContainer: Colors.grey[100],
      outline: Colors.grey[300],
    ),
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

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'OpenSans',
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
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1B1F34),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[800],
      thickness: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1B1F34),
    ),
    colorScheme: ColorScheme.dark(
      secondary:  Color(0xFF5D688F),
      primaryContainer:  Color(0xFF1B1F34),
      tertiaryContainer:Color(0xFF1B1F34),
      outline: Colors.grey[800],
    ),
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
