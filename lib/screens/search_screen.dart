import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/search_service.dart';
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
            custom.SearchBar(
              controller: _searchController,
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
              onClear: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
            
            const SizedBox(height: 24),
            
            // Search results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_hasSearched
                      ? const SearchEmptyState()
                      : _searchResults.isEmpty
                          ? const SearchNoResultsState()
                          : SearchResultsList(
                              results: _searchResults,
                              onSongTap: (song) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Reproduciendo ${song.name}...'),
                                  ),
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
