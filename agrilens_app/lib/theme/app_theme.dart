import 'package:flutter/material.dart';

class AppTheme {
  // Primary agricultural colors (high saturation/contrast for outdoor visibility)
  static const Color primaryGreen = Color(0xFF1B5E20);      // Deep Forest Green
  static const Color secondaryGreen = Color(0xFF4CAF50);    // Bright Field Green
  static const Color accentGold = Color(0xFFFFC107);        // Mustard Yellow/Gold (Alerts/Info)
  static const Color warningRed = Color(0xFFD32F2F);        // Safety Red
  static const Color waterBlue = Color(0xFF1976D2);         // Sky Blue for irrigation
  
  // Large accessible fonts
  static const double titleFontSize = 26.0;
  static const double subtitleFontSize = 20.0;
  static const double bodyFontSize = 18.0;
  static const double buttonFontSize = 20.0;

  // High Contrast Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: secondaryGreen,
        tertiary: accentGold,
        error: warningRed,
        brightness: Brightness.light,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      
      // Large readable fonts
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: primaryGreen),
        titleLarge: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold, color: Colors.black),
        bodyLarge: TextStyle(fontSize: bodyFontSize, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        labelLarge: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      
      // Spacious Touch Targets for inputs and cards
      cardTheme: const CardTheme(
        color: Colors.white,
        elevation: 3.0,
        margin: EdgeInsets.all(8.0),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60.0), // Large touch targets
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          textStyle: const TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
        ),
      ),
      
      iconTheme: const IconThemeData(
        size: 32.0, // Large icons
        color: primaryGreen,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2.0,
        toolbarHeight: 70.0,
        titleTextStyle: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // Sunlight High Contrast Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF81C784),      // Light Mint Green for high contrast on black
        secondary: Color(0xFF4CAF50),
        tertiary: accentGold,
        error: Color(0xFFEF5350),
        surface: Color(0xFF121212),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.black,
      
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: Color(0xFF81C784)),
        titleLarge: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: bodyFontSize, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
        labelLarge: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      
      cardTheme: const CardTheme(
        color: Color(0xFF1E1E1E),
        elevation: 0.0,
        margin: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white24, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF81C784),
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 60.0),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          textStyle: const TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
        ),
      ),
      
      iconTheme: const IconThemeData(
        size: 32.0,
        color: Color(0xFF81C784),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0.0,
        toolbarHeight: 70.0,
        titleTextStyle: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
