import 'package:blocify/services/jellyfin_service.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/search_service.dart';
import '../services/player_service.dart';
import '../models/song.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/search_empty_state.dart';
import '../widgets/search_no_results_state.dart';
import '../widgets/search_results_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService.instance;
  final JellyfinService _jellyfinService = JellyfinService.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = true;

  @override
  void initState() {
    super.initState();
    initSearch();
  }

  Future<void> initSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _searchResults = await _searchService.searchSongs("");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
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
            custom.SearchBar(
              controller: _searchController,
              onChanged: (value) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _performSearch(value);
                  }
                });
              },
              onSubmitted: _performSearch,
              onClear: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_hasSearched
                      ? const SearchEmptyState()
                      : _searchResults.isEmpty
                          ? const SearchNoResultsState()
                          : SearchResultsList(
                              results: _searchResults,
                              onSongTap: (song) async {
                                try {
                                  final playerService = PlayerService.instance;

                                  // Convertir Song a JellyfinTrack
                                  final jellyfinTrack = song.toJellyfinTrack();

                                  // Convertir toda la lista de resultados a JellyfinTracks
                                  final jellyfinPlaylist = _searchResults
                                      .map((s) => s.toJellyfinTrack())
                                      .toList();

                                  await playerService.playJellyfinTrack(
                                      jellyfinTrack,
                                      playlist: jellyfinPlaylist);

                                  // El mini player se mostrará automáticamente
                                } catch (e) {
                                  // Toast eliminado
                                }
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
