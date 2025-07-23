import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// MODELOS Truchos para simular datos
class Playlist {
  final String name;
  final String imageUrl;
  final int songCount;

  Playlist({
    required this.name,
    required this.imageUrl,
    required this.songCount,
  });
}

class Artist {
  final String name;
  final String imageUrl;

  Artist({
    required this.name,
    required this.imageUrl,
  });
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String selectedFilter = 'Playlists';

  final List<Playlist> playlists = [
    Playlist(
      name: 'Workout Mix',
      imageUrl: 'https://i.imgur.com/U4s7qzF.jpg',
      songCount: 20,
    ),
    Playlist(
      name: 'Chill Vibes',
      imageUrl: 'https://i.imgur.com/OH7dtFj.jpg',
      songCount: 10,
    ),
  ];

  final List<Artist> artists = [
    Artist(name: 'Queen', imageUrl: 'https://i.imgur.com/1bX5QH6.jpg'),
    Artist(name: 'The Weeknd', imageUrl: 'https://i.imgur.com/Yt9gBla.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Your Library'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8), // 0.02cm aprox en dp
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Playlists'),
                  selected: selectedFilter == 'Playlists',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  onSelected: (_) =>
                      setState(() => selectedFilter = 'Playlists'),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Artists'),
                  selected: selectedFilter == 'Artists',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  onSelected: (_) => setState(() => selectedFilter = 'Artists'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: selectedFilter == 'Playlists'
                    ? playlists.length
                    : artists.length,
                itemBuilder: (context, index) {
                  if (selectedFilter == 'Playlists') {
                    final playlist = playlists[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4), // ~0.01cm
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            playlist.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          playlist.name,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        subtitle:
                            Text('Playlist · ${playlist.songCount} songs'),
                      ),
                    );
                  } else {
                    final artist = artists[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4), // ~0.01cm
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(artist.imageUrl),
                          radius: 25,
                        ),
                        title: Text(
                          artist.name,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        subtitle: const Text('Artist'), // 👈 Agregado
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Theme.of(context).colorScheme.onBackground,
        unselectedItemColor: Theme.of(context).colorScheme.onBackground,
        currentIndex: 0,
        onTap: (_) {},
      ),
    );
  }
}
