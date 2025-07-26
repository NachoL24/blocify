import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth0_service.dart';
import '../services/playlist_service.dart';
import '../models/playlist_summary.dart';
import 'login_screen.dart';
import 'playlist_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Auth0Service _auth0Service = Auth0Service.instance;
  final PlaylistService _playlistService = PlaylistService.instance;
  List<PlaylistSummary> _topPlaylists = [];
  List<PlaylistSummary> _discoverPlaylists = [];
  List<PlaylistSummary> _userPlaylists = [];
  bool _isLoadingTopPlaylists = true;
  bool _isLoadingDiscoverPlaylists = true;
  bool _isLoadingUserPlaylists = true;

  @override
  void initState() {
    super.initState();
    _auth0Service.addListener(_onAuthStateChanged);
    _loadTopPlaylists();
    _loadDiscoverPlaylists();
    _loadUserPlaylists();
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

  Future<void> _loadTopPlaylists() async {
    try {
      final playlists = await _playlistService.getTopPlaylists();
      if (mounted) {
        setState(() {
          _topPlaylists = playlists;
          _isLoadingTopPlaylists = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTopPlaylists = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar playlists: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadDiscoverPlaylists() async {
    try {
      final playlists = await _playlistService.getDiscoverPlaylists();
      if (mounted) {
        setState(() {
          _discoverPlaylists = playlists;
          _isLoadingDiscoverPlaylists = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDiscoverPlaylists = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar playlists: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserPlaylists() async {
    try {
      final playlists = await _playlistService.getUserPlaylists();
      if (mounted) {
        setState(() {
          _userPlaylists = playlists;
          _isLoadingUserPlaylists = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserPlaylists = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar playlists: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      body: SingleChildScrollView(
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
              'Top Playlists',
              style: TextStyle(
                color: context.colors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              height: 200,
              child: _isLoadingTopPlaylists
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _topPlaylists.length,
                      itemBuilder: (context, index) {
                        final playlist = _topPlaylists[index];
                        return _DiscoverCard(
                          playlist: playlist,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistDetailScreen(
                                  playlistId: playlist.id,
                                  playlistName: playlist.name,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Discover',
              style: TextStyle(
                color: context.colors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              height: 200,
              child: _isLoadingDiscoverPlaylists
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _discoverPlaylists.length,
                      itemBuilder: (context, index) {
                        final playlist = _discoverPlaylists[index];
                        return _DiscoverCard(
                          playlist: playlist,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistDetailScreen(
                                  playlistId: playlist.id,
                                  playlistName: playlist.name,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
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
            
            SizedBox(
              height: 200,
              child: _isLoadingUserPlaylists
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _userPlaylists.length,
                      itemBuilder: (context, index) {
                        final playlist = _userPlaylists[index];
                        return _DiscoverCard(
                          playlist: playlist,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Abriendo ${playlist.name}...'),
                              ),
                            );
                          },
                        );
                      },
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

class _DiscoverCard extends StatelessWidget {
  final PlaylistSummary playlist;
  final VoidCallback onTap;

  const _DiscoverCard({
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: context.colors.secondaryText,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  playlist.name,
                  style: TextStyle(
                    color: context.colors.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                playlist.name,
                style: TextStyle(
                  color: context.colors.text,
                  fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            ),
          ],
        ),
      ),
    );
  }
}
