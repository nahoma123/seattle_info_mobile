import 'package:flutter/material.dart';
import 'card_theme.dart'; // Import the new CardTheme

class AppTheme {
  final Brightness brightness;
  final Color primaryColor;
  final Color secondaryColor;
  final CardTheme cardTheme; // Add CardTheme property

  AppTheme({
    required this.brightness,
    required this.primaryColor,
    required this.secondaryColor,
    required this.cardTheme, // Initialize in constructor
  });

  // Example of a light theme
  static final AppTheme lightTheme = AppTheme(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    secondaryColor: Colors.teal,
    cardTheme: CardTheme( // Provide a default CardTheme
      backgroundColor: Colors.white,
      textColor: Colors.black,
      elevation: 2.0,
    ),
  );

  // Example of a dark theme
  static final AppTheme darkTheme = AppTheme(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    secondaryColor: Colors.deepOrange,
    cardTheme: CardTheme( // Provide a default CardTheme
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      elevation: 4.0,
    ),
  );

  ThemeData toThemeData() {
    return ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: secondaryColor,
        brightness: brightness,
      ),
      // It's common to configure cardTheme directly in ThemeData
      // If your CardTheme properties align with ThemeData.cardTheme,
      // you can map them here.
      // For example:
      cardTheme: MaterialCardTheme(
         color: cardTheme.backgroundColor,
         elevation: cardTheme.elevation,
         // TextStyle for text within cards would typically be handled by TextTheme
         // or specific widget styling rather than CardTheme directly.
         // If cardTheme.textColor is intended for all text in cards,
         // you might need a more custom approach in your UI widgets.
      ),
    );
  }
}
