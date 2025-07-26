import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth0_service.dart';

class ProfileBottomSheet extends StatelessWidget {
  final Auth0Service auth0Service;
  final VoidCallback onLogout;

  const ProfileBottomSheet({
    super.key,
    required this.auth0Service,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: context.primaryColor,
                child: Icon(
                  Icons.person,
                  color: context.permanentWhite,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth0Service.currentUsername,
                    style: TextStyle(
                      color: context.colors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Usuario de Blocify',
                    style: TextStyle(
                      color: context.colors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
