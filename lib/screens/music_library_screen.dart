import 'package:flutter/material.dart';
import '../services/playlist_service.dart';
import '../models/playlist_summary.dart';
import '../theme/app_colors.dart';
import '../widgets/library_content.dart';

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

  Future<void> _createPlaylistDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: context.colors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear Nueva Playlist',
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
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar', style: TextStyle(color: context.colors.secondaryText)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;

                        try {
                          await _playlistService.createPlaylist(
                            name: name,
                            description: descriptionController.text.trim().isEmpty
                                ? 'Mi nueva playlist'
                                : descriptionController.text.trim(),
                          );
                          if (mounted) {
                            Navigator.of(context).pop();
                            _loadUserPlaylists();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al crear playlist: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: context.primaryColor),
                      child: Text('Crear', style: TextStyle(color: context.colors.permanentWhite)),
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

  Future<void> _deletePlaylist(int playlistId) async {
    try {
      await _playlistService.deletePlaylist(playlistId);
      _loadUserPlaylists();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar playlist: $e'), backgroundColor: Colors.red),
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
        centerTitle: true,
        title: Text(
          'Tu Biblioteca',
          style: TextStyle(
            color: context.colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: context.colors.text),
            onPressed: _createPlaylistDialog,
            tooltip: 'Crear nueva playlist',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: TextStyle(color: context.colors.text)))
          : LibraryContent(
        userPlaylists: _userPlaylists,
        isLoadingUserPlaylists: _isLoading,
        onPlaylistsUpdated: _loadUserPlaylists,
        onPlaylistTap: null,
      ),
    );
  }
}
