import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth0_service.dart';
import '../services/playlist_service.dart';
import '../models/playlist_summary.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/home_content.dart';
import '../widgets/library_content.dart';
import '../widgets/profile_bottom_sheet.dart';
import '../widgets/main_layout.dart';
import 'login_screen.dart';
import 'search_screen.dart';
import 'playlist_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Auth0Service _auth0Service = Auth0Service.instance;
  final PlaylistService _playlistService = PlaylistService.instance;
  List<PlaylistSummary> _topPlaylists = [];
  List<PlaylistSummary> _discoverPlaylists = [];
  List<PlaylistSummary> _userPlaylists = [];
  bool _isLoadingTopPlaylists = true;
  bool _isLoadingDiscoverPlaylists = true;
  bool _isLoadingUserPlaylists = true;
  int _selectedIndex = 0;

  // Para la navegación a playlist
  int? _selectedPlaylistId;
  String? _selectedPlaylistName;

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
      final playlists = _auth0Service.currentUser!.playlists;
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

  void _onItemTapped(int index) {
    setState(() {
      // Si se toca el mismo tab que ya está activo, recargar contenido
      if (_selectedIndex == index) {
        _reloadCurrentContent();
      }
      _selectedIndex = index;
      // Limpiar la selección de playlist al cambiar de tab
      _selectedPlaylistId = null;
      _selectedPlaylistName = null;
    });
  }

  void _navigateToPlaylist(int playlistId, String playlistName) {
    setState(() {
      _selectedPlaylistId = playlistId;
      _selectedPlaylistName = playlistName;
    });
  }

  void _navigateBackFromPlaylist() {
    setState(() {
      _selectedPlaylistId = null;
      _selectedPlaylistName = null;
    });
  }

  /// Recargar el contenido de la pantalla actual
  void _reloadCurrentContent() {
    switch (_selectedIndex) {
      case 0: // Home
        _reloadHomeContent();
        break;
      case 1: // Search
        // La búsqueda normalmente no necesita recarga automática
        break;
      case 2: // Library
        _reloadLibraryContent();
        break;
    }
  }

  /// Recargar contenido del Home
  void _reloadHomeContent() {
    setState(() {
      _isLoadingTopPlaylists = true;
      _isLoadingDiscoverPlaylists = true;
      _isLoadingUserPlaylists = true;
    });

    _loadTopPlaylists();
    _loadDiscoverPlaylists();
    _loadUserPlaylists();
  }

  /// Recargar contenido de la Library
  void _reloadLibraryContent() {
    setState(() {
      _isLoadingUserPlaylists = true;
    });

    _loadUserPlaylists();
  }

  Widget _buildCurrentScreen() {
    // Si hay una playlist seleccionada, mostrar su detalle
    if (_selectedPlaylistId != null && _selectedPlaylistName != null) {
      return _buildPlaylistDetailContent();
    }

    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const SearchScreen();
      case 2:
        return _buildLibraryContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return HomeContent(
      auth0Service: _auth0Service,
      topPlaylists: _topPlaylists,
      discoverPlaylists: _discoverPlaylists,
      userPlaylists: _userPlaylists,
      isLoadingTopPlaylists: _isLoadingTopPlaylists,
      isLoadingDiscoverPlaylists: _isLoadingDiscoverPlaylists,
      isLoadingUserPlaylists: _isLoadingUserPlaylists,
      onPlaylistTap: _navigateToPlaylist,
    );
  }

  Widget _buildLibraryContent() {
    return const LibraryContent();
  }

  Widget _buildPlaylistDetailContent() {
    return PlaylistDetailScreen(
      playlistId: _selectedPlaylistId!,
      playlistName: _selectedPlaylistName!,
      showBackButton: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: _selectedIndex == 1
            ? null
            : _selectedPlaylistId != null
                ? AppBar(
                    backgroundColor: context.colors.background,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: context.colors.text),
                      onPressed: _navigateBackFromPlaylist,
                    ),
                    title: Text(
                      'Playlist',
                      style: TextStyle(
                        color: context.colors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  )
                : CustomAppBar(
                    onProfileTap: () => _showProfileMenu(context),
                  ),
        body: _buildCurrentScreen(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: context.colors.drawer,
          selectedItemColor: context.primaryColor,
          unselectedItemColor: context.colors.secondaryText,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
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
      builder: (context) => ProfileBottomSheet(
        auth0Service: _auth0Service,
        onLogout: () => _handleLogout(context),
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
