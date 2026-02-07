import "package:flutter/material.dart";

/// # Themes
///
/// - provide both the light & dark mode based on the profile screen design
/// - to add another theme to the file use:
///```
/// ThemeData themeName = ThemeData();
///```

// to change the theme change : `themeMode: ThemeMode.` in `main.dart`

/// ## Light Mode Theme
///

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    brightness: Brightness.light,
    primary: const Color(0xFF4A90E2), // Blue accent color
    onPrimary: const Color(0xFFFFFFFF), // White text on primary
    primaryContainer: const Color(0xFFE3F2FD), // Light blue container
    onPrimaryContainer: const Color(0xFF1565C0),
    secondary: const Color(0xFF5C6BC0), // Secondary blue
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFFE8EAF6),
    onSecondaryContainer: const Color(0xFF1A237E),
    tertiary: const Color(0xFF42A5F5), // Lighter blue
    onTertiary: const Color(0xFFFFFFFF),
    tertiaryContainer: const Color(0xFFBBDEFB),
    onTertiaryContainer: const Color(0xFF0D47A1),
    error: const Color(0xFFBA1A1A),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: const Color(0xFFFFFFFF), // Pure white background
    onSurface: const Color(0xFF1F1F1F), // Dark text
    surfaceContainerHighest: const Color(0xFFF5F5F5), // Light gray for cards
    onSurfaceVariant: const Color(0xFF5F6368), // Gray text
    outline: const Color(0xFFE0E0E0), // Light gray borders
    outlineVariant: const Color(0xFFF5F5F5),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: const Color(0xFF1F1F1F),
    onInverseSurface: const Color(0xFFF5F5F5),
    inversePrimary: const Color(0xFF90CAF9),
  ),
);

/// ## Dark Mode Theme
///

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    brightness: Brightness.dark,
    primary: const Color(0xFF4A90E2), // Same blue accent color
    onPrimary: const Color(0xFFFFFFFF), // White text on primary
    primaryContainer: const Color(0xFF1565C0), // Darker blue container
    onPrimaryContainer: const Color(0xFFBBDEFB),
    secondary: const Color(0xFF5C6BC0), // Secondary blue
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFF283593),
    onSecondaryContainer: const Color(0xFFC5CAE9),
    tertiary: const Color(0xFF42A5F5), // Lighter blue
    onTertiary: const Color(0xFF000000),
    tertiaryContainer: const Color(0xFF0D47A1),
    onTertiaryContainer: const Color(0xFFE3F2FD),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    surface: const Color(0xFF0A0E1A), // Very dark blue/black background
    onSurface: const Color(0xFFE8EAF6), // Light text
    surfaceContainerHighest: const Color(
      0xFF1A1F2E,
    ), // Dark blue-gray for cards
    onSurfaceVariant: const Color(0xFFB0BEC5), // Light gray text
    outline: const Color(0xFF37474F), // Dark gray borders
    outlineVariant: const Color(0xFF263238),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: const Color(0xFFE1E8ED),
    onInverseSurface: const Color(0xFF0A0E1A),
    inversePrimary: const Color(0xFF1565C0),
  ),
);
