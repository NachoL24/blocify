import 'dart:convert';

import 'package:blocify/models/user.dart';
import 'package:blocify/services/http_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static UserService get instance => _instance;

  final HttpService _httpService = HttpService();

  /// Realizar login del usuario
  Future<User> login() async {
    try {
      final response = await _httpService.get('/api/users/login');
      if (response.statusCode == 200) {
        final userJson = jsonDecode(response.body);
        return User.fromJson(userJson);
      } else {
        throw Exception('Error al iniciar sesión: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }
}
