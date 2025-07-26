import 'package:auth0_flutter/auth0_flutter.dart';
import '../config/auth0_config.dart';

class Auth0Service {
  static Auth0Service? _instance;
  late Auth0 _auth0;

  Auth0Service._internal() {
    _auth0 = Auth0(Auth0Config.domain, Auth0Config.clientId);
  }

  static Auth0Service get instance {
    _instance ??= Auth0Service._internal();
    return _instance!;
  }

  Auth0 get auth0 => _auth0;

  /// Login with Auth0
  Future<Credentials?> login() async {
    try {
      final credentials = await _auth0.webAuthentication(scheme: Auth0Config.customScheme).login();
      return credentials;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// Logout from Auth0
  Future<void> logout() async {
    try {
      await _auth0.webAuthentication(scheme: Auth0Config.customScheme).logout();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  /// Check if user has valid credentials
  Future<Credentials?> getStoredCredentials() async {
    try {
      final credentials = await _auth0.credentialsManager.credentials();
      return credentials;
    } catch (e) {
      print('Get credentials error: $e');
      return null;
    }
  }

  /// Get user profile from credentials
  UserProfile? getUserProfileFromCredentials(Credentials credentials) {
    return credentials.user;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final credentials = await getStoredCredentials();
    return credentials != null && credentials.accessToken.isNotEmpty;
  }
}
