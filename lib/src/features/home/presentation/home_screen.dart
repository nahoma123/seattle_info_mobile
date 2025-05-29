import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_controller.dart'; // To use for sign out

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement actual home screen UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seattle Info Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome! This is the Home Screen.'),
      ),
    );
  }
}
