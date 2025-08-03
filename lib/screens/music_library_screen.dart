import 'package:flutter/material.dart';
import '../services/playlist_service.dart';
import '../services/artist_service.dart';
import '../models/playlist_summary.dart';
import '../models/artist.dart';
import '../theme/app_colors.dart';
import '../widgets/library_content.dart';
import 'create_playlist_screen.dart';

class MusicLibraryScreen extends StatefulWidget {
  final String userId;
  final String apiKey;

  const MusicLibraryScreen({
    super.key,
    required this.userId,
    required this.apiKey,
  });

  @override
  State<MusicLibraryScreen> createState() => _MusicLibraryScreenState();
}

class _MusicLibraryScreenState extends State<MusicLibraryScreen> {
  final PlaylistService _playlistService = PlaylistService.instance;
  final ArtistService _artistService = ArtistService();

  List<PlaylistSummary> _userPlaylists = [];
  List<ArtistSummary>? _userArtists;
  bool _isLoadingPlaylists = true;
  bool _isLoadingArtists = false;
  String? _error;
  String _selectedFilter = "playlists";

  @override
  void initState() {
    super.initState();
    _loadUserPlaylists();
  }

  Future<void> _loadUserPlaylists() async {
    final playlists = await PlaylistService().getUserPlaylists(widget.userId);
    setState(() {
      _userPlaylists = playlists;
    });

    try {
      final playlists = await _playlistService.getUserPlaylists(widget.userId);
      setState(() {
        _userPlaylists = playlists;
        _isLoadingPlaylists = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar playlists: $e';
        _isLoadingPlaylists = false;
      });
    }
  }

  Future<void> _loadUserArtists() async {
    if (_userArtists != null && _selectedFilter != 'artists') return;

    setState(() {
      _isLoadingArtists = true;
      _error = null;
    });

    try {
      final artists = await _artistService.getUserArtists();
      setState(() {
        _userArtists = artists;
        _isLoadingArtists = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar artistas: $e';
        _isLoadingArtists = false;
      });
    }
  }

  Future<void> _deletePlaylist(int playlistId) async {
    try {
      await _playlistService.deletePlaylist(playlistId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playlist eliminada correctamente'),
            duration: Duration(seconds: 2),
          ),
        );
        _loadUserPlaylists(); // Recargar la lista de playlists
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar playlist: $e'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToCreatePlaylist() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePlaylistScreen()),
    );
    if (created == true && mounted) {
      _loadUserPlaylists();
    }
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    if (filter == "playlists") {
      _loadUserPlaylists();
    } else if (filter == "artists") {
      _loadUserArtists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedFilter == "playlists") {
            await _loadUserPlaylists();
          } else {
            await _loadUserArtists();
          }
        },
        child: LibraryContent(
          userPlaylists: _userPlaylists,
          userArtists: _userArtists,
          isLoadingUserPlaylists: _isLoadingPlaylists,
          isLoadingUserArtists: _isLoadingArtists,
          onPlaylistsUpdated: _loadUserPlaylists,
          onPlaylistTap: (id, name) {
            // Navegación a playlist
          },
          onDelete: (playlistId) async { // Callback directo para eliminar
            await _deletePlaylist(playlistId);
          },
          onCreatePlaylist: _navigateToCreatePlaylist,
          selectedFilter: _selectedFilter,
          onFilterSelected: _onFilterSelected,
          error: _error,
        ),
      ),
    );
  }
}