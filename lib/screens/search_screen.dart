import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/search_service.dart';
import '../models/song.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await _searchService.searchSongs(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
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
            content: Text('Error al buscar: ${e.toString()}'),
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
        title: Text(
          'Buscar',
          style: TextStyle(
            color: context.colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: context.colors.card1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.lightGray.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: context.colors.text),
                decoration: InputDecoration(
                  hintText: 'Buscar canciones...',
                  hintStyle: TextStyle(color: context.colors.secondaryText),
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.colors.secondaryText,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: context.colors.secondaryText,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {}); // Para actualizar el suffixIcon
                  // Buscar después de una pequeña pausa para evitar demasiadas llamadas
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value) {
                      _performSearch(value);
                    }
                  });
                },
                onSubmitted: _performSearch,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Search results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_hasSearched
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                size: 64,
                                color: context.colors.secondaryText.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Busca tus canciones favoritas',
                                style: TextStyle(
                                  color: context.colors.secondaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Escribe el nombre de una canción para comenzar',
                                style: TextStyle(
                                  color: context.colors.secondaryText.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _searchResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.music_off,
                                    size: 64,
                                    color: context.colors.secondaryText.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se encontraron resultados',
                                    style: TextStyle(
                                      color: context.colors.secondaryText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Intenta con otro término de búsqueda',
                                    style: TextStyle(
                                      color: context.colors.secondaryText.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final song = _searchResults[index];
                                return _SearchResultTile(
                                  song: song,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Reproduciendo ${song.name}...'),
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
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.song,
    required this.onTap,
  });

  Color _getRandomColor() {
    final colors = [
      const Color(0xFFFF7043),
      const Color(0xFF42A5F5),
      const Color(0xFF4CAF50),
      const Color(0xFFFFA726),
      const Color(0xFFAB47BC),
      const Color(0xFF26A69A),
    ];
    return colors[song.id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: song.picture != null && song.picture!.isNotEmpty
              ? Image.memory(
                  song.picture!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _getRandomColor(),
                      child: Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 24,
                      ),
                    );
                  },
                )
              : Container(
                  color: _getRandomColor(),
                  child: Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
        ),
      ),
      title: Text(
        song.name,
        style: TextStyle(
          color: context.colors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            song.artist,
            style: TextStyle(
              color: context.colors.secondaryText,
              fontSize: 14,
            ),
          ),
          if (song.album.isNotEmpty)
            Text(
              song.album,
              style: TextStyle(
                color: context.colors.secondaryText.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: Icon(
        Icons.more_horiz,
        color: context.colors.secondaryText,
      ),
      onTap: onTap,
    );
  }
}
