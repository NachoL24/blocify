import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../theme/app_colors.dart';
import '../services/auth0_service.dart';
import '../services/playlist_service.dart';
import '../services/artist_service.dart';
import '../models/playlist_summary.dart';
import '../models/artist.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/home_content.dart';
import '../widgets/library_content.dart';
import '../widgets/main_layout.dart';
import 'create_playlist_screen.dart';
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
  final ArtistService _artistService = ArtistService();

  List<PlaylistSummary> _topPlaylists = [];
  List<PlaylistSummary> _discoverPlaylists = [];
  List<PlaylistSummary> _userPlaylists = [];
  List<ArtistSummary>? _userArtists;

  bool _isLoadingTopPlaylists = true;
  bool _isLoadingDiscoverPlaylists = true;
  bool _isLoadingUserPlaylists = true;
  bool _isLoadingUserArtists = false;

  int _selectedIndex = 0;
  String _selectedFilter = "playlists";

  int? _selectedPlaylistId;
  String? _selectedPlaylistName;
  String? _jellyfinApiKey;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _auth0Service.addListener(_onAuthStateChanged);
    _loadInitialData();
  }

  void _initializeServices() {
    // Configurar servicios con variables de entorno
    _jellyfinApiKey = dotenv.env['API_KEY'];
    _playlistService.configure();
    if (_jellyfinApiKey != null) {
      _artistService.configure(_jellyfinApiKey!);
    }
  }

  void _loadInitialData() {
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
      _handleError('top playlists', e);
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
      _handleError('discover playlists', e);
    }
  }

  Future<void> _loadUserPlaylists() async {
    try {
      if (_auth0Service.currentUser?.id != null) {
        final playlists = await _playlistService
            .getUserPlaylists(_auth0Service.currentUser!.id.toString());
        if (mounted) {
          setState(() {
            _userPlaylists = playlists;
            _isLoadingUserPlaylists = false;
          });
        }
      } else {
        _resetUserPlaylists();
      }
    } catch (e) {
      _handleError('user playlists', e);
    }
  }

  Future<void> _deletePlaylist(int playlistId) async {
    try {
      await PlaylistService.instance.deletePlaylist(playlistId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playlist eliminada correctamente')),
        );
        _loadUserPlaylists(); // Recargar la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadUserArtists() async {
    if (_userArtists != null && _selectedFilter != 'artists') return;

    setState(() => _isLoadingUserArtists = true);

    try {
      final artists = await _artistService.getUserArtists();
      if (mounted) {
        setState(() {
          _userArtists = artists;
          _isLoadingUserArtists = false;
        });
      }
    } catch (e) {
      _handleError('artists', e);
      setState(() => _isLoadingUserArtists = false);
    }
  }

  void _resetUserPlaylists() {
    if (mounted) {
      setState(() {
        _userPlaylists = [];
        _isLoadingUserPlaylists = false;
      });
    }
  }

  void _handleError(String resource, dynamic error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar $resource: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex == index) _reloadCurrentContent();
      _selectedIndex = index;
      _selectedPlaylistId = null;
      _selectedPlaylistName = null;
      _selectedFilter = "playlists"; // Resetear filtro al cambiar pestaña
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

  void _reloadCurrentContent() {
    switch (_selectedIndex) {
      case 0: _reloadHomeContent(); break;
      case 2: _reloadUserContent(); break;
    }
  }

  void _reloadHomeContent() {
    setState(() {
      _isLoadingTopPlaylists = true;
      _isLoadingDiscoverPlaylists = true;
    });
    _loadTopPlaylists();
    _loadDiscoverPlaylists();
  }

  void _reloadUserContent() {
    setState(() {
      _isLoadingUserPlaylists = true;
      if (_selectedFilter == "artists") _isLoadingUserArtists = true;
    });

    if (_selectedFilter == "playlists") {
      _loadUserPlaylists();
    } else {
      _loadUserArtists();
    }
  }

  void _onFilterSelected(String filter) {
    setState(() => _selectedFilter = filter);

    if (filter == "playlists") {
      _loadUserPlaylists();
    } else {
      _loadUserArtists();
    }
  }

  Widget _buildCurrentScreen() {
    if (_selectedPlaylistId != null && _selectedPlaylistName != null) {
      return _buildPlaylistDetailContent();
    }

    switch (_selectedIndex) {
      case 0: return _buildHomeContent();
      case 1: return const SearchScreen();
      case 2: return _buildLibraryContent();
      default: return _buildHomeContent();
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
    return LibraryContent(
      userPlaylists: _userPlaylists,
      userArtists: _userArtists,
      isLoadingUserPlaylists: _isLoadingUserPlaylists,
      isLoadingUserArtists: _isLoadingUserArtists,
      onPlaylistTap: _navigateToPlaylist,
      onPlaylistsUpdated: _reloadUserContent,
      onDelete: _deletePlaylist,
      selectedFilter: _selectedFilter,
      onFilterSelected: _onFilterSelected,
      onCreatePlaylist: () async {
        final created = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreatePlaylistScreen()),
        );
        if (created == true) _loadUserPlaylists();
      },
    );
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
            _selectedPlaylistName!,
            style: TextStyle(
              color: context.colors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        )
            : CustomAppBar(
          onSettingsTap: () =>
              Navigator.pushNamed(context, '/settings'),
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
}