import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:rue_app/screens/home_screen.dart';
import 'package:rue_app/screens/login_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:rue_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final bool _isLoggedIn =
      FirebaseAuth.instance.currentUser != null ? true : false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: FlexThemeData.light(
        scheme: FlexScheme.amber,
        useMaterial3: true,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.sakura,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: _isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
