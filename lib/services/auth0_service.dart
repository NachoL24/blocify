import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/auth0_config.dart';

class Auth0Service extends ChangeNotifier {
  static Auth0Service? _instance;
  late Auth0 _auth0;
  
  // Estado global de autenticación
  bool _isAuthenticated = false;
  Credentials? _currentCredentials;
  UserProfile? _currentUser;

  Auth0Service._internal() {
    _auth0 = Auth0(Auth0Config.domain, Auth0Config.clientId);
    _checkInitialAuthState();
  }

  static Auth0Service get instance {
    _instance ??= Auth0Service._internal();
    return _instance!;
  }

  // Getters para el estado
  bool get isAuthenticated => _isAuthenticated;
  Credentials? get currentCredentials => _currentCredentials;
  UserProfile? get currentUser => _currentUser;
  Auth0 get auth0 => _auth0;

  /// Verificar estado inicial de autenticación
  Future<void> _checkInitialAuthState() async {
    try {
      final credentials = await _auth0.credentialsManager.credentials();
      if (credentials != null && credentials.accessToken.isNotEmpty) {
        _setAuthenticatedState(credentials);
      } else {
        _clearAuthenticatedState();
      }
    } catch (e) {
      print('Error checking initial auth state: $e');
      _clearAuthenticatedState();
    }
  }

  /// Establecer estado autenticado
  void _setAuthenticatedState(Credentials credentials) {
    print('Estado autenticado: ${credentials.accessToken} ${credentials.idToken} ${credentials.refreshToken} ${credentials.expiresAt}');
    // imprimimos los datos del usuario
    print('Usuario autenticado: ${credentials.user.toString()}');
    print('Datos del usuario:');
    print('  - Name: ${credentials.user.name}');
    print('  - Email: ${credentials.user.email}'); 
    print('  - Picture: ${credentials.user.pictureUrl}');
    print('  - Nickname: ${credentials.user.nickname}');
    print('  - Given name: ${credentials.user.givenName}');
    print('  - Sub: ${credentials.user.sub}');
    print('  - Updated at: ${credentials.user.updatedAt}');
    print('  - Custom claims: ${credentials.user.customClaims}');
    _isAuthenticated = true;
    _currentCredentials = credentials;
    _currentUser = credentials.user;
    notifyListeners();
  }

  /// Limpiar estado autenticado
  void _clearAuthenticatedState() {
    _isAuthenticated = false;
    _currentCredentials = null;
    _currentUser = null;
    notifyListeners();
  }

  /// Login with Auth0
  Future<Credentials?> login() async {
    try {
      final credentials = await _auth0.webAuthentication(scheme: Auth0Config.customScheme).login();
      if (credentials != null) {
        _setAuthenticatedState(credentials);
        print('Login exitoso');
      }
      return credentials;
    } catch (e) {
      print('Login error: $e');
      _clearAuthenticatedState();
      return null;
    }
  }

  /// Logout from Auth0
  Future<void> logout() async {
    try {
      // First logout from the web session
      await _auth0.webAuthentication(scheme: Auth0Config.customScheme).logout();
      // Then clear stored credentials locally
      await _auth0.credentialsManager.clearCredentials();
      // Clear the global state
      _clearAuthenticatedState();
      print('Sesión cerrada correctamente');
    } catch (e) {
      print('Logout error: $e');
      // Even if web logout fails, clear local credentials and state
      try {
        await _auth0.credentialsManager.clearCredentials();
        _clearAuthenticatedState();
      } catch (clearError) {
        print('Error clearing credentials: $clearError');
        // Force clear state even if credential clearing fails
        _clearAuthenticatedState();
      }
    }
  }

  /// Verificar y actualizar estado de autenticación
  Future<void> checkAuthenticationStatus() async {
    await _checkInitialAuthState();
  }

  /// Check if user has valid credentials (método legacy para compatibilidad)
  Future<Credentials?> getStoredCredentials() async {
    return _currentCredentials;
  }

  /// Get user profile from credentials (método legacy para compatibilidad)
  UserProfile getUserProfileFromCredentials(Credentials credentials) {
    return credentials.user;
  }

  /// Get current username
  String get currentUsername {
    if (_currentUser != null) {
      return _currentUser!.name ?? _currentUser!.email ?? 'Usuario';
    }
    return 'Usuario';
  }
}
