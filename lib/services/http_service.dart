import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth0_service.dart';
import '../config/backend_config.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  Auth0Service? _auth0Service;

  // Lazy initialization to avoid circular dependency
  Auth0Service get _auth0ServiceInstance {
    _auth0Service ??= Auth0Service.instance;
    return _auth0Service!;
  }

  /// Realizar una petición GET autenticada
  Future<http.Response> get(String endpoint) async {
    final token = await _auth0ServiceInstance.getBackendToken();
    if (token == null) {
      throw Exception('No hay token de autenticación disponible');
    }

    final url = Uri.parse('${BackendConfig.baseUrl}$endpoint');

    print('GET Request to: $url');
    print('Token: ${token}...');

    final response = await http.get(
      url,
      headers: BackendConfig.authHeaders(token),
    );

    _logResponse('GET', endpoint, response);
    return response;
  }

  /// Realizar una petición POST autenticada
  Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    final token = await _auth0ServiceInstance.getBackendToken();
    if (token == null) {
      throw Exception('No hay token de autenticación disponible');
    }

    final url = Uri.parse('${BackendConfig.baseUrl}$endpoint');

    print('POST Request to: $url');
    print('Token: ${token}...');
    if (body != null) {
      print('Body: ${jsonEncode(body)}');
    }

    final response = await http.post(
      url,
      headers: BackendConfig.authHeaders(token),
      body: body != null ? jsonEncode(body) : null,
    );

    _logResponse('POST', endpoint, response);
    return response;
  }

  /// Realizar una petición PUT autenticada
  Future<http.Response> put(String endpoint,
      {Map<String, dynamic>? body}) async {
    final token = await _auth0ServiceInstance.getBackendToken();
    if (token == null) {
      throw Exception('No hay token de autenticación disponible');
    }

    final url = Uri.parse('${BackendConfig.baseUrl}$endpoint');

    final response = await http.put(
      url,
      headers: BackendConfig.authHeaders(token),
      body: body != null ? jsonEncode(body) : null,
    );

    _logResponse('PUT', endpoint, response);
    return response;
  }

  /// Realizar una petición DELETE autenticada
  Future<http.Response> delete(String endpoint) async {
    final token = await _auth0ServiceInstance.getBackendToken();
    if (token == null) {
      throw Exception('No hay token de autenticación disponible');
    }

    final url = Uri.parse('${BackendConfig.baseUrl}$endpoint');

    final response = await http.delete(
      url,
      headers: BackendConfig.authHeaders(token),
    );

    _logResponse('DELETE', endpoint, response);
    return response;
  }

  /// Log de respuestas para debugging
  void _logResponse(String method, String endpoint, http.Response response) {
    print('$method $endpoint - Status: ${response.statusCode}');
    if (response.statusCode >= 400) {
      print('Error Response: ${response.body}');
    } else {
      final body = response.body;
      print('Response: $body');
    }
  }

  /// Verificar si el token es válido haciendo una petición de prueba
  Future<bool> validateToken() async {
    try {
      final response = await get('/auth/validate'); // Endpoint de validación
      return response.statusCode == 200;
    } catch (e) {
      print('Error validando token: $e');
      return false;
    }
  }
}
