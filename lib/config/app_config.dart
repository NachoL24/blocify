class AppConfig {
  static const String backendBaseUrl = String.fromEnvironment(
    'BASE_BACKEND_URL',
    defaultValue: 'http://dorrego-server.brazilsouth.cloudapp.azure.com:9080',
  );

  static const String apiPlaylistsEndpoint = '/api/playlists';

  static String get playlistsUrl => '$backendBaseUrl$apiPlaylistsEndpoint';
}
