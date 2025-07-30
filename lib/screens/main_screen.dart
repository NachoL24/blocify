import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth0_service.dart';
import '../services/playlist_service.dart';
import '../models/playlist_summary.dart';
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
        if (mounted) {
          setState(() {
            _userPlaylists = [];
            _isLoadingUserPlaylists = false;
          });
        }
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
        _reloadUserPlaylistsEverywhere();
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

  /// Recargar contenido de la Library y Home (para mantener sincronizadas las playlists)
  void _reloadUserPlaylistsEverywhere() {
    print('🔄 Recargando playlists del usuario en toda la app...');
    setState(() {
      _isLoadingUserPlaylists = true;
    });

    _loadUserPlaylists();
  }

  void _showEditPlaylistDialog(int playlistId) async {
    // Encontrar la playlist actual
    final currentPlaylist = _userPlaylists.firstWhere(
      (playlist) => playlist.id == playlistId,
      orElse: () => throw Exception('Playlist no encontrada'),
    );

    final nameController = TextEditingController(text: currentPlaylist.name);
    final descriptionController =
        TextEditingController(text: currentPlaylist.description);

    showDialog(
      context: context,
      builder: (BuildContext context2) {
        return Dialog(
          backgroundColor: context.colors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar Playlist',
                  style: TextStyle(
                    color: context.colors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: context.colors.text),
                  decoration: InputDecoration(
                    labelText: 'Nombre de la playlist',
                    labelStyle: TextStyle(color: context.colors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: context.colors.lightGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: context.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: context.colors.text),
                  decoration: InputDecoration(
                    hintText: 'Descripción (opcional)',
                    hintStyle: TextStyle(color: context.colors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: context.colors.lightGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: context.primaryColor),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context2).pop(),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: context.colors.secondaryText),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isNotEmpty) {
                          try {
                            await _playlistService.updatePlaylist(
                              playlistId: playlistId,
                              name: nameController.text.trim(),
                              description:
                                  descriptionController.text.trim().isEmpty
                                      ? 'Mi playlist actualizada'
                                      : descriptionController.text.trim(),
                            );

                            if (mounted) {
                              Navigator.of(context2).pop();
                              print(
                                  '🔄 Playlist actualizada, recargando playlists...');
                              // Actualizar el nombre en la variable local
                              _selectedPlaylistName =
                                  nameController.text.trim();
                              // Recargar las playlists para reflejar los cambios
                              _reloadUserPlaylistsEverywhere();
                            }
                          } catch (e) {
                            if (mounted) {
                              print('❌ Error al actualizar playlist: $e');
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                      ),
                      child: Text(
                        'Guardar',
                        style: TextStyle(color: context.colors.permanentWhite),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
    return LibraryContent(
      userPlaylists: _userPlaylists,
      isLoadingUserPlaylists: _isLoadingUserPlaylists,
      onPlaylistTap: _navigateToPlaylist,
      onPlaylistsUpdated: _reloadUserPlaylistsEverywhere,
      selectedFilter: "playlists",
      onFilterSelected: (filter) {

        if (filter == "playlists") {
          _reloadUserPlaylistsEverywhere();
        }
        // TODO: Manejar el caso de "artists" si es necesario
      },

      onCreatePlaylist: () async {
        final created = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreatePlaylistScreen()),
        );
        if (created == true) {
          _reloadUserPlaylistsEverywhere();
        }
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
                    actions: [
                      IconButton(
                        icon: Icon(Icons.edit, color: context.colors.text),
                        onPressed: () =>
                            _showEditPlaylistDialog(_selectedPlaylistId!),
                      ),
                    ],
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
