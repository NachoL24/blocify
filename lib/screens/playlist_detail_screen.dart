import 'package:flutter/material.dart';
import '../services/playlist_service.dart';
import '../services/player_service.dart';
import '../models/playlist.dart';
import '../widgets/playlist_content.dart';
import '../widgets/main_layout.dart';
import '../screens/create_block_screen.dart';
import '../theme/app_colors.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final int playlistId;
  final String playlistName;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool isOwner; // 1. Añadimos este parámetro

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
    this.showBackButton = false,
    this.onBackPressed,
    this.isOwner = false, // 2. Valor por defecto false
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final PlaylistService _playlistService = PlaylistService.instance;
  Playlist? _playlist;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylistDetails();
  }

  Future<void> _loadPlaylistDetails() async {
    try {
      final playlist = await _playlistService.getPlaylistById(widget.playlistId);
      if (mounted) {
        setState(() {
          _playlist = playlist;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar playlist: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 3. Añadimos este método para navegar a la pantalla de creación de bloques
  void _navigateToCreateBlockScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateBlockScreen(
          playlistId: widget.playlistId,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadPlaylistDetails();
    }
  }

  void _showEditPlaylistDialog() {
    if (_playlist == null) return;

    final nameController = TextEditingController(text: _playlist!.name);
    final descriptionController = TextEditingController(text: _playlist!.description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                      onPressed: () => Navigator.of(context).pop(),
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
                              playlistId: widget.playlistId,
                              name: nameController.text.trim(),
                              description: descriptionController.text.trim().isEmpty
                                  ? 'Mi playlist actualizada'
                                  : descriptionController.text.trim(),
                            );

                            if (mounted) {
                              Navigator.of(context).pop();
                              _loadPlaylistDetails();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
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

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      backgroundColor: context.colors.background,
      appBar: widget.showBackButton
          ? AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.text),
          onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
        ),
        title: Text(
          'Playlist',
          style: TextStyle(
            color: context.colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.isOwner) // 4. Solo mostrar botón de edición si es owner
            IconButton(
              icon: Icon(Icons.edit, color: context.colors.text),
              onPressed: _showEditPlaylistDialog,
            ),
        ],
      )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _playlist == null
          ? Center(
        child: Text(
          'No se pudo cargar la playlist',
          style: TextStyle(color: context.colors.text),
        ),
      )
          : PlaylistContent(
        playlist: _playlist!,
        onSongTap: (song) async {
          try {
            final playerService = PlayerService.instance;
            await playerService.playFromPlaylist(
              widget.playlistId,
              song.itemId,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reproduciendo ${song.name}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al reproducir: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        isOwner: widget.isOwner, // 5. Pasamos el parámetro isOwner
        onCreateBlock: _navigateToCreateBlockScreen, // 6. Pasamos el método
        onRefresh: _loadPlaylistDetails, // 7. Pasamos el método de refresh
      ),
    );

    return widget.showBackButton ? MainLayout(child: content) : content;
  }
}