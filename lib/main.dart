import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app/app.dart'; // Your main app widget

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Wrap your root widget with ProviderScope
  runApp(const ProviderScope(child: MyApp()));
}
