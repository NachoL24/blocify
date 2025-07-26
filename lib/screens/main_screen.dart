import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth0_service.dart';
import '../services/playlist_service.dart';
import '../models/playlist_summary.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/home_content.dart';
import '../widgets/library_content.dart';
import '../widgets/profile_bottom_sheet.dart';
import 'login_screen.dart';
import 'search_screen.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCurrentScreen() {
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
    );
  }

  Widget _buildLibraryContent() {
    return const LibraryContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: _selectedIndex == 1 ? null : CustomAppBar(
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
