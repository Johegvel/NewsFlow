class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:3000/api/v1';

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
}
