import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  
  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.music_note_rounded,
              color: const Color(0xFF1DB954),
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'Blocify',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // Aquí implementarás el perfil del usuario
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo personalizado
            Text(
              'Hola, $username 👋',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              '¿Qué quieres escuchar hoy?',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Sección de acciones rápidas
            const Text(
              'Acceso rápido',
              style: TextStyle(
                color: Colors.white,
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
            
            // Sección de playlists
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
        backgroundColor: const Color(0xFF282828),
        selectedItemColor: const Color(0xFF1DB954),
        unselectedItemColor: Colors.grey,
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
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFF1DB954),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
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
          color: isCreate ? const Color(0xFF1DB954) : const Color(0xFF282828),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isCreate ? Colors.black : Colors.white,
          size: 28,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isCreate ? const Color(0xFF1DB954) : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
