import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth0_service.dart';

class WelcomeHeader extends StatelessWidget {
  final Auth0Service auth0Service;

  const WelcomeHeader({
    super.key,
    required this.auth0Service,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, ${auth0Service.currentUser?.givenName}!',
          style: TextStyle(
            color: context.colors.text,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '¿Qué quieres escuchar hoy?',
          style: TextStyle(
            color: context.colors.secondaryText,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
