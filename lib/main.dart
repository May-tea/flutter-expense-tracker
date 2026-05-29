import 'package:app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/auth/auth.dart';
import 'screens/auth/verify_email.dart';
import 'screens/splash.dart';

final _firebase = FirebaseAuth.instance;

final kColorScheme = ColorScheme.fromSeed(
  seedColor: const .fromRGBO(0, 61, 55, 1),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance App',
      theme: .new(fontFamily: 'Poppins', colorScheme: kColorScheme),
      home: StreamBuilder(
        stream: _firebase.userChanges(),
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

          return Scaffold(
            appBar: AppBar(
              title: const Text('Welcome'),
              actions: [
                IconButton(
                  onPressed: () {
                    _firebase.signOut();
                  },
                  icon: Icon(Icons.exit_to_app, color: kColorScheme.primary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
