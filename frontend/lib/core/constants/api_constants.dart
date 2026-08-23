class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue:
        'https://flews-backend-388073050451.us-central1.run.app/api/v1',
  );

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String me = '$baseUrl/auth/me';
  static const String users = '$baseUrl/auth/users';

  // Communities
  static const String communities = '$baseUrl/communities';

  // Posts
  static const String posts = '$baseUrl/posts';

  // Reports
  static const String reports = '$baseUrl/reports';

  // Saved Posts
  static const String savedPosts = '$baseUrl/saved_posts';

  // Profile and settings
  static const String profile = '$baseUrl/me/profile';
  static const String preferences = '$baseUrl/me/preferences';
  static const String readHistory = '$baseUrl/me/read_history';
}
