import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../home/screens/home_screen.dart';
import '../../splash/splash_screen.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';
import 'verify_email_screen.dart';

final AuthService _authService = .instance;

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges(),
      builder: (ctx, asyncSnapshot) {
        if (asyncSnapshot.connectionState == .waiting) {
          return const SplashScreen();
        }

        final user = asyncSnapshot.data;

        if (user == null) {
          return const AuthScreen();
        }

        if (!user.emailVerified) {
          return VerifyEmail(email: user.email ?? '');
        }

        return const HomeScreen();
      },
    );
  }
}
