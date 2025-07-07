import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const BlocifyApp());
}

class BlocifyApp extends StatelessWidget {
  const BlocifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blocify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DB954), // Spotify green
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}


