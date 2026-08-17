import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/community_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/report_model.dart';
import '../models/saved_post_model.dart';

abstract class RemoteApiDataSource {
  Future<UserModel> login(String email);
  Future<UserModel> register(String name, String email);
  Future<List<UserModel>> fetchAvailableUsers();

  Future<List<CommunityModel>> fetchCommunities();

  Future<List<PostModel>> fetchPosts({int? communityId, String? filter});
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

  Future<void> createReaction({
    required int postId,
    required int userId,
  });

  Future<void> savePost({
    required int postId,
    required int userId,
  });
  Future<List<SavedPostModel>> fetchSavedPosts(int userId);
  Future<void> deleteSavedPost(int savedPostId);

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

  RemoteApiDataSourceImpl({http.Client? client}) : client = client ?? http.Client();

  @override
  Future<UserModel> login(String email) async {
    final response = await client.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim()}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return UserModel.fromJson(data);
    }
    throw Exception(data['error'] ?? 'Error al iniciar sesión');
  }

  @override
  Future<UserModel> register(String name, String email) async {
    final response = await client.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return UserModel.fromJson(data);
    }
    throw Exception(
      data['error'] ?? (data['errors'] is List ? data['errors'].join(', ') : 'Error al registrarse'),
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
  Future<List<PostModel>> fetchPosts({int? communityId, String? filter}) async {
    final queryParams = <String, String>{};
    if (communityId != null) queryParams['community_id'] = communityId.toString();
    if (filter != null) queryParams['filter'] = filter;

    final baseUri = communityId != null
        ? Uri.parse('${ApiConstants.communities}/$communityId/posts')
        : Uri.parse(ApiConstants.posts);

    final uri = baseUri.replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await client.get(uri);
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => PostModel.fromJson(e)).toList();
    }
    throw Exception('Error al cargar publicaciones');
  }

  @override
  Future<PostModel> fetchPost(int postId) async {
    final response = await client.get(Uri.parse('${ApiConstants.posts}/$postId'));
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
    final response = await client.post(
      Uri.parse('${ApiConstants.communities}/$communityId/posts'),
      headers: {'Content-Type': 'application/json'},
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
    final response = await client.get(Uri.parse('${ApiConstants.posts}/$postId/comments'));
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
    final response = await client.post(
      Uri.parse('${ApiConstants.posts}/$postId/comments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'comment': {
          'user_id': userId,
          'content': content,
        },
      }),
    );

    if (response.statusCode == 201) {
      return CommentModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al publicar comentario');
  }

  @override
  Future<void> createReaction({required int postId, required int userId}) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.posts}/$postId/reactions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reaction': {
          'user_id': userId,
          'kind': 'like',
        },
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al registrar reacción');
    }
  }

  @override
  Future<void> savePost({required int postId, required int userId}) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.posts}/$postId/saved_posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'saved_post': {
          'user_id': userId,
        },
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al guardar publicación');
    }
  }

  @override
  Future<List<SavedPostModel>> fetchSavedPosts(int userId) async {
    final response = await client.get(Uri.parse('${ApiConstants.baseUrl}/users/$userId/saved_posts'));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => SavedPostModel.fromJson(e)).toList();
    }
    throw Exception('Error al cargar guardados');
  }

  @override
  Future<void> deleteSavedPost(int savedPostId) async {
    final response = await client.delete(Uri.parse('${ApiConstants.savedPosts}/$savedPostId'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar publicación guardada');
    }
  }

  @override
  Future<void> createReport({required int postId, required String reason, required int userId}) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.posts}/$postId/reports'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'report': {
          'user_id': userId,
          'reason': reason,
        },
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al enviar reporte');
    }
  }

  @override
  Future<List<ReportModel>> fetchReports() async {
    final response = await client.get(Uri.parse(ApiConstants.reports));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => ReportModel.fromJson(e)).toList();
    }
    throw Exception('Error al cargar reportes');
  }

  @override
  Future<ReportModel> updateReport(int reportId, String status) async {
    final response = await client.patch(
      Uri.parse('${ApiConstants.reports}/$reportId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'report': {
          'status': status,
        },
      }),
    );

    if (response.statusCode == 200) {
      return ReportModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al actualizar reporte');
  }
}
