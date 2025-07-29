import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:blocify/models/user.dart';
import 'package:blocify/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../config/auth0_config.dart';

class Auth0Service extends ChangeNotifier {
  static Auth0Service? _instance;
  late Auth0 _auth0;
  UserService? _userService;

  // Estado global de autenticación
  bool _isAuthenticated = false;
  Credentials? _currentCredentials;
  User? _currentUser;

  Auth0Service._internal() {
    _auth0 = Auth0(Auth0Config.domain, Auth0Config.clientId);
    _checkInitialAuthState();
  }

  // Lazy initialization to avoid circular dependency
  UserService get _userServiceInstance {
    _userService ??= UserService();
    return _userService!;
  }

  static Auth0Service get instance {
    _instance ??= Auth0Service._internal();
    return _instance!;
  }

  // Getters para el estado
  bool get isAuthenticated => _isAuthenticated;
  Credentials? get currentCredentials => _currentCredentials;
  User? get currentUser => _currentUser;
  Auth0 get auth0 => _auth0;

  /// Verificar estado inicial de autenticación
  Future<void> _checkInitialAuthState() async {
    try {
      final credentials = await _auth0.credentialsManager.credentials();
      if (credentials.accessToken.isNotEmpty) {
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
  Future<void> _setAuthenticatedState(Credentials credentials) async {
    print('Estado autenticado: ${credentials.accessToken}');
    print('ID Token: ${credentials.idToken}');
    print('Token Type: ${credentials.tokenType}');
    print('Expires At: ${credentials.expiresAt}');
    print('Scope: ${credentials.scopes}');

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
    print('  - accessToken: ${credentials.accessToken}');

    // Analizar el token
    _analyzeToken(credentials.accessToken);

    _isAuthenticated = true;
    _currentCredentials = credentials;

    // Ahora que tenemos el accessToken, hacer login en el backend
    _currentUser = await _userServiceInstance.login();
    print('✅ Login en backend exitoso');

    notifyListeners();
  }

  /// Analizar el contenido del token JWT
  void _analyzeToken(String token) {
    try {
      print('=== ANÁLISIS COMPLETO DEL TOKEN JWT ===');
      print('Token completo: $token');
      print('Longitud del token: ${token.length}');

      // Dividir el token JWT en sus partes
      final parts = token.split('.');
      print('Número de partes del token: ${parts.length}');

      if (parts.length != 3) {
        print('❌ Token JWT inválido: no tiene 3 partes');
        print('Partes encontradas: $parts');
        return;
      }

      print('Parte 1 (Header): ${parts[0]}');
      print('Parte 2 (Payload): ${parts[1]}');
      print('Parte 3 (Signature): ${parts[2]}');

      // Decodificar el header
      try {
        final headerDecoded =
            utf8.decode(base64Url.decode(base64Url.normalize(parts[0])));
        print('✅ JWT Header decodificado: $headerDecoded');

        final headerJson = jsonDecode(headerDecoded);
        print('Header algoritmo: ${headerJson['alg']}');
        print('Header tipo: ${headerJson['typ']}');
        if (headerJson.containsKey('kid')) {
          print('Header kid: ${headerJson['kid']}');
        }
      } catch (e) {
        print('❌ Error decodificando header: $e');
      }

      // Decodificar el payload
      try {
        final payloadDecoded =
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        print('✅ JWT Payload decodificado: $payloadDecoded');

        // Parsear el payload como JSON
        final payload = jsonDecode(payloadDecoded);
        print('=== CLAIMS DEL TOKEN ===');
        print('Audience (aud): ${payload['aud']}');
        print('Issuer (iss): ${payload['iss']}');
        print('Subject (sub): ${payload['sub']}');
        print('Expires (exp): ${payload['exp']}');
        print('Issued at (iat): ${payload['iat']}');
        print('Not before (nbf): ${payload['nbf']}');
        print('Scope: ${payload['scope']}');
        print('Grant type: ${payload['gty']}');
        print('Authorization details: ${payload['azp']}');

        // Verificar expiración
        if (payload['exp'] != null) {
          final expTime =
              DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
          final now = DateTime.now();
          print('Expira en: $expTime');
          print('Tiempo actual: $now');
          print('¿Token expirado?: ${now.isAfter(expTime)}');
        }

        // Mostrar todos los claims
        print('=== TODOS LOS CLAIMS ===');
        payload.forEach((key, value) {
          print('$key: $value');
        });
      } catch (e) {
        print('❌ Error decodificando payload: $e');
      }

      // Verificar la firma (solo mostrar info, no podemos validarla sin la clave)
      print('=== INFORMACIÓN DE LA FIRMA ===');
      print(
          'Firma (primeros 50 chars): ${parts[2].substring(0, parts[2].length > 50 ? 50 : parts[2].length)}...');
      print('Longitud de la firma: ${parts[2].length}');

      print('=== FIN ANÁLISIS TOKEN ===');
    } catch (e) {
      print('❌ Error analizando token: $e');
      print('Stack trace: ${StackTrace.current}');
    }
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
      print('=== INICIANDO LOGIN CON AUTH0 ===');
      print('Domain: ${Auth0Config.domain}');
      print('Client ID: ${Auth0Config.clientId}');
      print('Custom Scheme: ${Auth0Config.customScheme}');
      print('Audience: ${Auth0Config.audience}');

      // Configurar parámetros adicionales si hay audiencia
      final webAuth =
          _auth0.webAuthentication(scheme: Auth0Config.customScheme);

      final credentials = Auth0Config.audience.isNotEmpty
          ? await webAuth.login(
              parameters: {
                'audience': Auth0Config.audience,
                'scope': 'openid profile email read:playlists write:playlists',
              },
            )
          : await webAuth.login();

      print('✅ Login exitoso, analizando credenciales...');
      _setAuthenticatedState(credentials);

      // Verificar configuración de Auth0
      _verifyAuth0Configuration();

      return credentials;
    } catch (e) {
      print('❌ Login error: $e');
      print('Stack trace: ${StackTrace.current}');
      _clearAuthenticatedState();
      return null;
    }
  }

  /// Verificar configuración de Auth0
  void _verifyAuth0Configuration() {
    print('=== VERIFICANDO CONFIGURACIÓN AUTH0 ===');

    // Verificar dominio
    if (!Auth0Config.domain.contains('.auth0.com') &&
        !Auth0Config.domain.contains('.eu.auth0.com')) {
      print('⚠️  Dominio sospechoso: ${Auth0Config.domain}');
      print('   Debería terminar en .auth0.com o .eu.auth0.com');
    } else {
      print('✅ Dominio Auth0 válido: ${Auth0Config.domain}');
    }

    // Verificar Client ID
    if (Auth0Config.clientId.length < 20) {
      print('⚠️  Client ID sospechoso (muy corto): ${Auth0Config.clientId}');
    } else {
      print('✅ Client ID tiene longitud adecuada');
    }

    // Verificar custom scheme
    if (!Auth0Config.customScheme.startsWith('com.') &&
        !Auth0Config.customScheme.startsWith('app.')) {
      print('⚠️  Custom scheme sospechoso: ${Auth0Config.customScheme}');
    } else {
      print('✅ Custom scheme válido: ${Auth0Config.customScheme}');
    }

    print('=== FIN VERIFICACIÓN CONFIGURACIÓN ===');
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

  /// Obtener token para el backend
  /// Este método intenta obtener un token con la audiencia correcta para el backend
  Future<String?> getBackendToken() async {
    try {
      if (_currentCredentials != null) {
        // Verificar si el token actual es válido
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (_currentCredentials!.expiresAt.millisecondsSinceEpoch ~/ 1000 >
            now) {
          print('Usando token existente');
          return _currentCredentials!.accessToken;
        }
      }

      // Intentar renovar el token
      final credentials = await _auth0.credentialsManager.credentials();
      if (credentials.accessToken.isNotEmpty) {
        _setAuthenticatedState(credentials);
        return credentials.accessToken;
      }

      print('No hay token válido disponible');
      return null;
    } catch (e) {
      print('Error obteniendo token para backend: $e');
      return null;
    }
  }

  /// Obtener token con audiencia específica (para APIs específicas)
  Future<String?> getTokenForAudience(String audience) async {
    try {
      // Esto requeriría una configuración específica en Auth0
      // Por ahora, devolvemos el token actual
      return getBackendToken();
    } catch (e) {
      print('Error obteniendo token para audiencia $audience: $e');
      return null;
    }
  }
}
