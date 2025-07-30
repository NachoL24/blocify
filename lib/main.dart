import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/player.dart';
import 'screens/music_library_screen.dart';
import 'screens/create_playlist_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const BlocifyApp());
}

class BlocifyApp extends StatelessWidget {
  const BlocifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Blocify',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeService.instance.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginScreen(),
            '/home': (context) => const MainScreen(),
            '/player': (context) => const PlayerPage(),
            '/library': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              final userId = args?['userId'] ?? '';
              return LibraryScreen(userId: userId);
            },
            '/create-playlist': (context) => const CreatePlaylistScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
