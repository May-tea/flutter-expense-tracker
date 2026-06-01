import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../expenses/screens/home_screen.dart';
import '../../splash/splash_screen.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'verify_email_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const SplashScreen(),
      error: (_, _) => const AuthScreen(),
      data: (user) {
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
