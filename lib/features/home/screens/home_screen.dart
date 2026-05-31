import 'package:flutter/material.dart';

import '../../auth/services/auth_service.dart';

final AuthService _authService = .instance;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            onPressed: () => _authService.signOut(),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
    );
  }
}
