import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth0_service.dart';
import '../services/theme_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Auth0Service _auth0Service = Auth0Service.instance;
  final ThemeService _themeService = ThemeService.instance;

  @override
  void initState() {
    super.initState();
    _auth0Service.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _auth0Service.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (!_auth0Service.isAuthenticated && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configuración',
          style: TextStyle(
            color: context.colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoSection(),
            const SizedBox(height: 32),
            _buildSettingsSection(),
            const SizedBox(height: 32),
            _buildLogoutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    final user = _auth0Service.currentCredentials?.user;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.card1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Usuario',
            style: TextStyle(
              color: context.colors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: context.primaryColor,
                backgroundImage: user?.pictureUrl != null
                    ? NetworkImage(user!.pictureUrl.toString())
                    : null,
                child: user?.pictureUrl == null
                    ? Icon(
                        Icons.person,
                        color: context.permanentWhite,
                        size: 30,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Usuario',
                      style: TextStyle(
                        color: context.colors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'email@ejemplo.com',
                      style: TextStyle(
                        color: context.colors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.card1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuraciones',
            style: TextStyle(
              color: context.colors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _themeService,
            builder: (context, _) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: context.colors.text,
                ),
                title: Text(
                  'Tema',
                  style: TextStyle(
                    color: context.colors.text,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  _themeService.isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                  style: TextStyle(
                    color: context.colors.secondaryText,
                    fontSize: 14,
                  ),
                ),
                trailing: Switch(
                  value: _themeService.isDarkMode,
                  onChanged: (value) {
                    _themeService.toggleTheme();
                  },
                  activeColor: context.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: context.colors.card1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
        onTap: () => _showLogoutDialog(),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.colors.card1,
          title: Text(
            'Cerrar Sesión',
            style: TextStyle(color: context.colors.text),
          ),
          content: Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(color: context.colors.secondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: context.colors.secondaryText),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _handleLogout();
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      await _auth0Service.logout();
    } catch (e) {
      if (mounted) {
        // Toast eliminado
      }
    }
  }
}
