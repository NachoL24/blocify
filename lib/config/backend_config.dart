import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackendConfig {
  // URL del backend
  static String get baseUrl => dotenv.env['BASE_BACKEND_URL'] ?? '';

  // Audiencia del API (debe coincidir con la configurada en Auth0)
  static String get audience => dotenv.env['AUTH0_AUDIENCE'] ?? '';

  // Scopes necesarios para tu API
  static List<String> get scopes => [
    'read:playlists',
    'write:playlists',
    'read:songs',
    'write:songs',
  ];

  // Headers por defecto
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Headers con autenticación
  static Map<String, String> authHeaders(String token) => {
        'Authorization': 'Bearer $token',
      };

  // URL base para Jellyfin
  static String get jellyfinBaseUrl => dotenv.env['BASE_JELLYFIN_URL'] ?? '';

}
