import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth0_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Auth0Service _auth0Service = Auth0Service.instance;

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
      // Si el usuario ya no está autenticado, navegar al login
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
        title: Row(
          children: [
            Icon(
              Icons.music_note_rounded,
              color: context.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Blocify',
              style: TextStyle(
                color: context.colors.text,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: context.colors.text),
            onPressed: () {
              _showProfileMenu(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${_auth0Service.currentUser?.givenName}!',
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
            
            const SizedBox(height: 32),
            
            Text(
              'Acceso rápido',
              style: TextStyle(
                color: context.colors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.favorite,
                    title: 'Me Gusta',
                    subtitle: 'Tus canciones favoritas',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Función en desarrollo')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.history,
                    title: 'Recientes',
                    subtitle: 'Reproducidas recientemente',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Función en desarrollo')),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Tus Playlists',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView(
                children: [
                  _PlaylistTile(
                    title: 'Mi Playlist #1',
                    subtitle: '12 canciones',
                    icon: Icons.queue_music,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Abriendo playlist...')),
                      );
                    },
                  ),
                  _PlaylistTile(
                    title: 'Favoritos Rock',
                    subtitle: '8 canciones',
                    icon: Icons.music_note,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Abriendo playlist...')),
                      );
                    },
                  ),
                  _PlaylistTile(
                    title: 'Crear nueva playlist',
                    subtitle: 'Toca para crear',
                    icon: Icons.add,
                    isCreate: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Función en desarrollo')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: context.colors.drawer,
        selectedItemColor: context.primaryColor,
        unselectedItemColor: context.colors.secondaryText,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Biblioteca',
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
                      _auth0Service.currentUsername,
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
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _handleLogout(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await _auth0Service.logout();
      // La navegación se maneja automáticamente por el listener _onAuthStateChanged
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.card1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: context.primaryColor,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: context.colors.text,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: context.colors.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isCreate;

  const _PlaylistTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isCreate = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isCreate ? context.primaryColor : context.colors.card1,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isCreate ? context.permanentWhite : context.colors.text,
          size: 28,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isCreate ? context.primaryColor : context.colors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: context.colors.secondaryText,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
