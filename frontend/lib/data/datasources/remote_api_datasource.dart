import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';
import '../models/community_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/report_model.dart';
import '../models/saved_post_model.dart';
import '../models/profile_stats_model.dart';
import '../models/user_preferences_model.dart';
import '../../domain/entities/user_preferences_entity.dart';

abstract class RemoteApiDataSource {
  void setAuthToken(String? token);
  void setRefreshToken(String? token);
  void setOnSessionRefreshed(
    Future<void> Function(AuthSessionModel newSession)? callback,
  );
  Future<bool> refreshSession();

  Future<AuthSessionModel> login(String email, String password);
  Future<AuthSessionModel> register(String name, String email, String password);
  Future<List<UserModel>> fetchAvailableUsers();
  Future<List<CommunityModel>> fetchCommunities();
  Future<List<PostModel>> fetchPosts({
    int? communityId,
    String? filter,
    String? sortBy,
  });
  Future<PostModel> fetchPost(int postId);
  Future<PostModel> createPost({
    required int communityId,
    required String title,
    required String content,
    required String postType,
    required int userId,
  });
  Future<List<CommentModel>> fetchComments(int postId);
  Future<CommentModel> createComment({
    required int postId,
    required String content,
    required int userId,
  });
  Future<int> createReaction({required int postId, required int userId});
  Future<void> deleteReaction(int reactionId);
  Future<SavedPostModel> savePost({required int postId, required int userId});
  Future<List<SavedPostModel>> fetchSavedPosts(int userId);
  Future<void> deleteSavedPost(int savedPostId, {int? postId});
  Future<int> markPostRead(int postId);
  Future<ProfileStatsModel> fetchProfileStats();
  Future<UserPreferencesModel> fetchPreferences();
  Future<UserPreferencesModel> updatePreferences(
    UserPreferencesEntity preferences,
  );
  Future<void> clearReadHistory();
  Future<void> createReport({
    required int postId,
    required String reason,
    required int userId,
  });
  Future<List<ReportModel>> fetchReports();
  Future<ReportModel> updateReport(int reportId, String status);
}

class RemoteApiDataSourceImpl implements RemoteApiDataSource {
  final http.Client client;
  String? _authToken;
  String? _refreshToken;
  Future<void> Function(AuthSessionModel newSession)? _onSessionRefreshed;
  Future<bool>? _refreshFuture;

  RemoteApiDataSourceImpl({http.Client? client})
    : client = client ?? http.Client();

  Map<String, String> _headers({bool authenticated = false}) {
    return {
      'Content-Type': 'application/json',
      if (authenticated && _authToken != null)
        'Authorization': 'Bearer $_authToken',
    };
  }

  @override
  void setAuthToken(String? token) {
    _authToken = token;
  }

  @override
  void setRefreshToken(String? token) {
    _refreshToken = token;
  }

  @override
  void setOnSessionRefreshed(
    Future<void> Function(AuthSessionModel newSession)? callback,
  ) {
    _onSessionRefreshed = callback;
  }

  @override
  Future<bool> refreshSession() async {
    return await _trySilentRefresh();
  }

  Future<bool> _trySilentRefresh() async {
    final token = _refreshToken;
    if (token == null || token.isEmpty) return false;

    if (_refreshFuture != null) {
      return await _refreshFuture!;
    }

    _refreshFuture = _performRefresh(token);
    try {
      final success = await _refreshFuture!;
      return success;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<bool> _performRefresh(String token) async {
    try {
      final response = await client.post(
        Uri.parse(ApiConstants.refresh),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final newSession = AuthSessionModel.fromJson(data);
          _authToken = newSession.token;
          if (newSession.refreshToken != null) {
            _refreshToken = newSession.refreshToken;
          }
          if (_onSessionRefreshed != null) {
            await _onSessionRefreshed!(newSession);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<http.Response> _sendWithAutoRefresh(
    Future<http.Response> Function() requestSender,
  ) async {
    final response = await requestSender();
    if (response.statusCode == 401 && _refreshToken != null) {
      final refreshed = await _trySilentRefresh();
      if (refreshed) {
        return await requestSender();
      }
    }
    return response;
  }

  Future<http.Response> _authenticatedGet(Uri uri) {
    return _sendWithAutoRefresh(
      () => client.get(uri, headers: _headers(authenticated: true)),
    );
  }

  Future<http.Response> _authenticatedPost(Uri uri, {Object? body}) {
    return _sendWithAutoRefresh(
      () => client.post(
        uri,
        headers: _headers(authenticated: true),
        body: body,
      ),
    );
  }

  Future<http.Response> _authenticatedDelete(Uri uri) {
    return _sendWithAutoRefresh(
      () => client.delete(uri, headers: _headers(authenticated: true)),
    );
  }

  Future<http.Response> _authenticatedPatch(Uri uri, {Object? body}) {
    return _sendWithAutoRefresh(
      () => client.patch(
        uri,
        headers: _headers(authenticated: true),
        body: body,
      ),
    );
  }

  @override
  Future<AuthSessionModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse(ApiConstants.login),
      headers: _headers(),
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return AuthSessionModel.fromJson(data);
    }
    throw Exception(data['error'] ?? 'Error al iniciar sesión');
  }

  @override
  Future<AuthSessionModel> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await client.post(
      Uri.parse(ApiConstants.register),
      headers: _headers(),
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return AuthSessionModel.fromJson(data);
    }
    throw Exception(
      data['error'] ??
          (data['errors'] is List
              ? data['errors'].join(', ')
              : 'Error al registrarse'),
    );
  }

  @override
  Future<List<UserModel>> fetchAvailableUsers() async {
    final response = await client.get(Uri.parse(ApiConstants.users));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => UserModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<CommunityModel>> fetchCommunities() async {
    final response = await client.get(Uri.parse(ApiConstants.communities));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => CommunityModel.fromJson(e)).toList();
    }
    throw Exception('Error al cargar comunidades');
  }

  @override
  Future<List<PostModel>> fetchPosts({
    int? communityId,
    String? filter,
    String? sortBy,
  }) async {
    final queryParams = <String, String>{};
    if (communityId != null) {
      queryParams['community_id'] = communityId.toString();
    }
    if (filter != null) queryParams['filter'] = filter;
    if (sortBy != null) queryParams['sort_by'] = sortBy;

    final baseUri = communityId != null
        ? Uri.parse('${ApiConstants.communities}/$communityId/posts')
        : Uri.parse(ApiConstants.posts);

    final uri = baseUri.replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await _authenticatedGet(uri);
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => PostModel.fromJson(e)).toList();
    }
    throw Exception('Error al cargar publicaciones');
  }

  @override
  Future<PostModel> fetchPost(int postId) async {
    final response = await _authenticatedGet(
      Uri.parse('${ApiConstants.posts}/$postId'),
    );
    if (response.statusCode == 200) {
      return PostModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al cargar publicación');
  }

  @override
  Future<PostModel> createPost({
    required int communityId,
    required String title,
    required String content,
    required String postType,
    required int userId,
  }) async {
    final response = await _authenticatedPost(
      Uri.parse('${ApiConstants.communities}/$communityId/posts'),
      body: jsonEncode({
        'post': {
          'user_id': userId,
          'title': title,
          'content': content,
          'post_type': postType,
          'status': 'published',
        },
      }),
    );

    if (response.statusCode == 201) {
      return PostModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear publicación');
  }

  @override
  Future<List<CommentModel>> fetchComments(int postId) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.posts}/$postId/comments'),
    );
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => CommentModel.fromJson(e)).toList();
    }
    throw Exception('Error al cargar comentarios');
  }

  @override
  Future<CommentModel> createComment({
    required int postId,
    required String content,
    required int userId,
  }) async {
    final response = await _authenticatedPost(
      Uri.parse('${ApiConstants.posts}/$postId/comments'),
      body: jsonEncode({
        'comment': {'user_id': userId, 'content': content},
      }),
    );

    if (response.statusCode == 201) {
      return CommentModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al publicar comentario');
  }

  @override
  Future<int> createReaction({required int postId, required int userId}) async {
    final response = await _authenticatedPost(
      Uri.parse('${ApiConstants.posts}/$postId/reactions'),
      body: jsonEncode({
        'reaction': {'user_id': userId, 'kind': 'like'},
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final id = data is Map<String, dynamic> ? data['id'] : null;
      if (id is int) return id;
      final parsedId = int.tryParse(id?.toString() ?? '');
      if (parsedId != null) return parsedId;
    }
    throw Exception('Error al registrar reacción');
  }

  @override
  Future<void> deleteReaction(int reactionId) async {
    final response = await _authenticatedDelete(
      Uri.parse('${ApiConstants.baseUrl}/reactions/$reactionId'),
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la reacción');
    }
  }

  @override
  Future<SavedPostModel> savePost({
    required int postId,
    required int userId,
  }) async {
    final response = await _authenticatedPost(
      Uri.parse('${ApiConstants.posts}/$postId/saved_posts'),
      body: jsonEncode({
        'saved_post': {'user_id': userId},
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) return SavedPostModel.fromJson(data);
    }
    throw Exception('Error al guardar publicación (${response.statusCode})');
  }

  @override
  Future<List<SavedPostModel>> fetchSavedPosts(int userId) async {
    final response = await _authenticatedGet(
      Uri.parse('${ApiConstants.baseUrl}/users/$userId/saved_posts'),
    );
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => SavedPostModel.fromJson(e)).toList();
    }
    throw Exception('Error al cargar guardados');
  }

  @override
  Future<void> deleteSavedPost(int savedPostId, {int? postId}) async {
    final uri = postId != null
        ? Uri.parse('${ApiConstants.posts}/$postId/saved_posts')
        : Uri.parse('${ApiConstants.savedPosts}/$savedPostId');
    final response = await _authenticatedDelete(uri);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar publicación guardada');
    }
  }

  @override
  Future<int> markPostRead(int postId) async {
    final response = await _authenticatedPost(
      Uri.parse('${ApiConstants.posts}/$postId/post_reads'),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final count = data['reads_count'];
        return count is int
            ? count
            : int.tryParse(count?.toString() ?? '') ?? 0;
      }
    }
    throw Exception('Error al registrar la lectura');
  }

  @override
  Future<ProfileStatsModel> fetchProfileStats() async {
    final response = await _authenticatedGet(
      Uri.parse(ApiConstants.profile),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) return ProfileStatsModel.fromJson(data);
    }
    throw Exception('Error al cargar las estadísticas del perfil');
  }

  @override
  Future<UserPreferencesModel> fetchPreferences() async {
    final response = await _authenticatedGet(
      Uri.parse(ApiConstants.preferences),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return UserPreferencesModel.fromJson(data);
      }
    }
    throw Exception('Error al cargar las preferencias');
  }

  @override
  Future<UserPreferencesModel> updatePreferences(
    UserPreferencesEntity preferences,
  ) async {
    final response = await _authenticatedPatch(
      Uri.parse(ApiConstants.preferences),
      body: jsonEncode({
        'preferences': {
          'reading_history_enabled': preferences.readingHistoryEnabled,
          'personalization_enabled': preferences.personalizationEnabled,
          'morning_digest_enabled': preferences.morningDigestEnabled,
          'curation_alerts_enabled': preferences.curationAlertsEnabled,
        },
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return UserPreferencesModel.fromJson(data);
      }
    }
    throw Exception('Error al guardar las preferencias');
  }

  @override
  Future<void> clearReadHistory() async {
    final response = await _authenticatedDelete(
      Uri.parse(ApiConstants.readHistory),
    );
    if (response.statusCode != 204) {
      throw Exception('Error al borrar el historial de lectura');
    }
  }

  @override
  Future<void> createReport({
    required int postId,
    required String reason,
    required int userId,
  }) async {
    final response = await _authenticatedPost(
      Uri.parse('${ApiConstants.posts}/$postId/reports'),
      body: jsonEncode({
        'report': {'user_id': userId, 'reason': reason},
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al enviar reporte');
    }
  }

  @override
  Future<List<ReportModel>> fetchReports() async {
    final response = await _authenticatedGet(
      Uri.parse(ApiConstants.reports),
    );
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => ReportModel.fromJson(e)).toList();
    }
    throw Exception('Error al cargar reportes');
  }

  @override
  Future<ReportModel> updateReport(int reportId, String status) async {
    final response = await _authenticatedPatch(
      Uri.parse('${ApiConstants.reports}/$reportId'),
      body: jsonEncode({
        'report': {'status': status},
      }),
    );

    if (response.statusCode == 200) {
      return ReportModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al actualizar reporte');
  }
}
