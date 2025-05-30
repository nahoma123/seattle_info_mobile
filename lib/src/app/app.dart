import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart'; // Your GoRouter configuration

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    // Define a custom color scheme
    const primaryColor = Colors.teal; // Example primary color (Seattle-ish green/blue)
    const secondaryColor = Colors.amber; // Example accent color

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      // You can further customize:
      // surface: Colors.white,
      // background: Colors.grey[100],
      // error: Colors.redAccent,
      // onPrimary: Colors.white,
      // onSecondary: Colors.black,
      // onSurface: Colors.black87,
      // onBackground: Colors.black87,
      // onError: Colors.white,
      brightness: Brightness.light, // Or Brightness.dark for a dark theme base
    );

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary, // For title and icons
        elevation: 4.0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.secondaryContainer, // A lighter shade for chips
        labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
        selectedColor: colorScheme.secondary,
        checkmarkColor: colorScheme.onSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      ),

      cardTheme: CardThemeData( // <--- MODIFIED HERE
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      ),

      // You can also define textTheme, pageTransitionsTheme, etc.
      textTheme: ThemeData.light().textTheme.copyWith( // Start with default light theme text
         titleLarge: TextStyle(color: colorScheme.onBackground, fontWeight: FontWeight.bold),
         titleMedium: TextStyle(color: colorScheme.onBackground.withOpacity(0.9)),
         bodyLarge: TextStyle(color: colorScheme.onSurface),
         bodyMedium: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
         labelLarge: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold), // For ElevatedButton text
      ),

      // Ensure scaffoldBackgroundColor is set if you want a specific background
      scaffoldBackgroundColor: colorScheme.background,

    );

    return MaterialApp.router(
      title: 'Seattle Info', // App name
      theme: theme, // Apply the customized theme
      // darkTheme: theme, // Optionally define a darkTheme too
      // themeMode: ThemeMode.system, // Or ThemeMode.light, ThemeMode.dark
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      routeInformationProvider: goRouter.routeInformationProvider,
    );
  }
}