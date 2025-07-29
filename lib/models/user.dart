import 'package:blocify/models/playlist_summary.dart';

class User {
  final int id;
  final String name;
  final String email;
  final List<PlaylistSummary> playlists;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.playlists,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      playlists: (json['playlists'] as List<dynamic>?)
              ?.map((playlist) => PlaylistSummary(
                    id: playlist['id'],
                    name: playlist['name'],
                  ))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'playlists': playlists,
    };
  }
}
