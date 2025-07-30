// screens/music_library_screen.dart
import 'package:flutter/material.dart';
import '../services/playlist_service.dart';
import '../models/playlist_summary.dart';
import '../theme/app_colors.dart';
import '../widgets/library_content.dart';
import 'create_playlist_screen.dart';

class LibraryScreen extends StatefulWidget {
  final String userId;

  const LibraryScreen({super.key, required this.userId});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final PlaylistService _playlistService = PlaylistService.instance;

  List<PlaylistSummary> _userPlaylists = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = "playlists";

  @override
  void initState() {
    super.initState();
    _loadUserPlaylists();
  }

  Future<void> _loadUserPlaylists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final playlists = await _playlistService.getUserPlaylists(widget.userId);
      setState(() {
        _userPlaylists = playlists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar playlists: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToCreatePlaylist() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePlaylistScreen()),
    );
    if (created == true) {
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
      // TODO: cargar artistas cuando tengas el service
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: TextStyle(color: context.colors.text)))
          : LibraryContent(
        userPlaylists: _userPlaylists,
        isLoadingUserPlaylists: _isLoading,
        onPlaylistsUpdated: _loadUserPlaylists,
        onPlaylistTap: null,
        onCreatePlaylist: _navigateToCreatePlaylist, // Pasamos el callback
        selectedFilter: _selectedFilter,
        onFilterSelected: _onFilterSelected,
      ),
    );
  }
}