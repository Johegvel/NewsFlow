import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/community.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/reaction.dart';
import '../models/report.dart';
import '../models/saved_post.dart';
import '../models/interest.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000/api/v1';

  String _errorMessage(String message, http.Response response) {
    return '$message (${response.statusCode}): ${response.body}';
  }

  List<dynamic> _decodeList(String body, {String? key}) {
    final decoded = jsonDecode(body);

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic> &&
        key != null &&
        decoded[key] is List) {
      return decoded[key] as List;
    }

    throw const FormatException('La respuesta no contiene una lista válida');
  }

  Future<Map<String, dynamic>> _fetchPostJson(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$postId'));

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage('No se pudo cargar la publicación', response),
      );
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<List<Community>> fetchCommunities() async {
    final response = await http.get(Uri.parse('$baseUrl/communities'));

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage('No se pudieron cargar las comunidades', response),
      );
    }

    final data = _decodeList(response.body);

    return data
        .map((item) => Community.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage('No se pudieron cargar las publicaciones', response),
      );
    }

    final data = _decodeList(response.body);

    return data
        .map((item) => Post.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Post> fetchPost(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$postId'));

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage('No se pudo cargar la publicación', response),
      );
    }

    return Post.fromJson(Map<String, dynamic>.from(jsonDecode(response.body)));
  }

  Future<List<Comment>> fetchComments(int postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/comments'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage('No se pudieron cargar los comentarios', response),
      );
    }

    final data = _decodeList(response.body);

    return data
        .map((item) => Comment.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Comment> createComment(int postId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: await AuthService.authHeaders(json: true),
      body: jsonEncode({
        'comment': {'content': content},
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _errorMessage('No se pudo crear el comentario', response),
      );
    }

    return Comment.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body)),
    );
  }

  Future<Reaction> createReaction(int postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/reactions'),
      headers: await AuthService.authHeaders(json: true),
      body: jsonEncode({'kind': 0}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _errorMessage('No se pudo registrar la reacción', response),
      );
    }

    return Reaction.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body)),
    );
  }

  Future<Post> createPost({
    required int communityId,
    required String title,
    required String content,
    required String postType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/communities/$communityId/posts'),
      headers: await AuthService.authHeaders(json: true),
      body: jsonEncode({
        'post': {
          'title': title,
          'content': content,
          'post_type': postType,
          'status': 'published',
        },
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _errorMessage('No se pudo crear la publicación', response),
      );
    }

    return Post.fromJson(Map<String, dynamic>.from(jsonDecode(response.body)));
  }

  Future<void> createReport(int postId, String reason) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/reports'),
      headers: await AuthService.authHeaders(json: true),
      body: jsonEncode({
        'report': {'reason': reason},
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_errorMessage('No se pudo enviar el reporte', response));
    }
  }

  Future<List<Report>> fetchReports() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports'),
      headers: await AuthService.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage('No se pudieron cargar los reportes', response),
      );
    }

    final data = _decodeList(response.body, key: 'reports');

    final reports = <Report>[];

    for (final rawItem in data) {
      final item = Map<String, dynamic>.from(rawItem);

      if (item['post'] == null && item['post_id'] != null) {
        item['post'] = await _fetchPostJson(item['post_id'] as int);
      }

      if (item['user'] == null) {
        item['user'] = {'name': item['user_name'] ?? 'Usuario'};
      }

      reports.add(Report.fromJson(item));
    }

    return reports;
  }

  Future<Report> updateReport(int reportId, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/reports/$reportId'),
      headers: await AuthService.authHeaders(json: true),
      body: jsonEncode({
        'report': {'status': status},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage('No se pudo actualizar el reporte', response),
      );
    }

    return Report.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body)),
    );
  }

  Future<int> savePost(int postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/saved_posts'),
      headers: await AuthService.authHeaders(json: true),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _errorMessage('No se pudo guardar la publicación', response),
      );
    }

    final data = Map<String, dynamic>.from(jsonDecode(response.body));

    return (data['id'] as num).toInt();
  }

  Future<List<SavedPost>> fetchSavedPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me/saved_posts'),
      headers: await AuthService.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          'No se pudieron cargar las publicaciones guardadas',
          response,
        ),
      );
    }

    final data = _decodeList(response.body, key: 'saved_posts');

    final savedPosts = <SavedPost>[];

    for (final rawItem in data) {
      final item = Map<String, dynamic>.from(rawItem);

      if (item['post'] == null && item['post_id'] != null) {
        item['post'] = await _fetchPostJson(item['post_id'] as int);
      }

      if (item['post'] == null) {
        throw const FormatException(
          'La publicación guardada no contiene información del post',
        );
      }

      savedPosts.add(SavedPost.fromJson(item));
    }

    return savedPosts;
  }

  Future<void> deleteSavedPost(int savedPostId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/saved_posts/$savedPostId'),
      headers: await AuthService.authHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        _errorMessage('No se pudo eliminar la publicación guardada', response),
      );
    }
  }

  Future<List<Interest>> fetchInterests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/interests'),
      headers: await AuthService.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage('No se pudieron cargar los intereses', response),
      );
    }

    final data = _decodeList(response.body, key: 'interests');

    return data
        .map((item) => Interest.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<Interest>> fetchUserInterests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me/interests'),
      headers: await AuthService.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage('No se pudieron cargar tus intereses', response),
      );
    }

    final data = _decodeList(response.body, key: 'interests');

    return data
        .map((item) => Interest.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> updateUserInterests(List<int> interestIds) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/me/interests'),
      headers: await AuthService.authHeaders(json: true),
      body: jsonEncode({'interest_ids': interestIds}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage('No se pudieron actualizar los intereses', response),
      );
    }
  }

  Future<List<Post>> fetchPersonalizedFeed() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me/feed'),
      headers: await AuthService.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage('No se pudo cargar el feed personalizado', response),
      );
    }

    final data = _decodeList(response.body, key: 'posts');

    return data
        .map((item) => Post.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> deleteReaction(int reactionId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/reactions/$reactionId'),
      headers: await AuthService.authHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_errorMessage('No se pudo quitar la reacción', response));
    }
  }

  Future<List<Reaction>> fetchReactions(int postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/reactions'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage('No se pudieron cargar las reacciones', response),
      );
    }

    final data = _decodeList(response.body);

    return data
        .map((item) => Reaction.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
