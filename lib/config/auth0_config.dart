import 'package:flutter_dotenv/flutter_dotenv.dart';

class Auth0Config {
  static String get domain => dotenv.env['AUTH0_DOMAIN'] ?? '';
  static String get clientId => dotenv.env['AUTH0_CLIENT_ID'] ?? '';
  static String get clientSecret => dotenv.env['AUTH0_CLIENT_SECRET'] ?? '';
  static String get customScheme => dotenv.env['AUTH0_CUSTOM_SCHEME'] ?? 'com.example.blocify';
}
