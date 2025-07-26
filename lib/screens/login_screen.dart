import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'home_screen.dart';
import '../theme/app_colors.dart';
import '../services/auth0_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final Auth0Service _auth0Service = Auth0Service.instance;

  @override
  void initState() {
    super.initState();
    _checkExistingLogin();
  }

  void _checkExistingLogin() async {
    final isAuthenticated = await _auth0Service.isAuthenticated();
    if (isAuthenticated && mounted) {
      final credentials = await _auth0Service.getStoredCredentials();
      if (credentials != null) {
        _navigateToHome(credentials);
      }
    }
  }

  void _handleAuth0Login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final credentials = await _auth0Service.login();
      
      if (credentials != null && mounted) {
        _navigateToHome(credentials);
      } else if (mounted) {
        _showError('Error al iniciar sesión');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al iniciar sesión: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToHome(Credentials credentials) {
    final userProfile = _auth0Service.getUserProfileFromCredentials(credentials);
    final username = userProfile?.name ?? userProfile?.email ?? 'Usuario';
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(username: username),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 80,
                      color: context.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Blocify',
                      style: TextStyle(
                        color: context.colors.text,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu música, tus playlists',
                      style: TextStyle(
                        color: context.colors.secondaryText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAuth0Login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: context.permanentWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: context.permanentWhite,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Iniciar Sesión con Auth0',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Autenticación segura con Auth0',
                      style: TextStyle(
                        color: context.colors.secondaryText,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
