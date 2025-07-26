import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/player.dart';
import 'screens/music_library_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Asegurar que los widgets están inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  runApp(const BlocifyApp());
}

class BlocifyApp extends StatelessWidget {
  const BlocifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blocify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(username: ''),
        '/player': (context) => const PlayerPage(),
        '/library': (context) => const MusicLibraryScreen(),
      },
    );
  }
}
