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

  Future<List<Community>> fetchCommunities() async {
    final response = await http.get(Uri.parse('$baseUrl/communities'));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las comunidades');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((item) => Community.fromJson(item)).toList();
  }

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las publicaciones');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((item) => Post.fromJson(item)).toList();
  }

  Future<Post> fetchPost(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$postId'));

    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar la publicación');
    }

    return Post.fromJson(jsonDecode(response.body));
  }

  Future<List<Comment>> fetchComments(int postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/comments'),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los comentarios');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((item) => Comment.fromJson(item)).toList();
  }

  Future<Comment> createComment(int postId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: await AuthService.authHeaders(json: true),
      body: jsonEncode({
        'comment': {'content': content},
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('No se pudo crear el comentario');
    }

    return Comment.fromJson(jsonDecode(response.body));
  }

  Future<Reaction> createReaction(int postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/reactions'),
      headers: await AuthService.authHeaders(json: true),
      body: jsonEncode({
        'reaction': {'kind': 'like'},
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('No se pudo registrar la reacción');
    }

    return Reaction.fromJson(jsonDecode(response.body));
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

    if (response.statusCode != 201) {
      throw Exception('No se pudo crear la publicación');
    }

    return Post.fromJson(jsonDecode(response.body));
  }

  Future<void> createReport(int postId, String reason) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/reports'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'report': {'user_id': 1, 'reason': reason},
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('No se pudo enviar el reporte');
    }
  }

  Future<List<Report>> fetchReports() async {
    final response = await http.get(Uri.parse('$baseUrl/reports'));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los reportes');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((item) => Report.fromJson(item)).toList();
  }

  Future<Report> updateReport(int reportId, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/reports/$reportId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'report': {'status': status},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo actualizar el reporte');
    }

    return Report.fromJson(jsonDecode(response.body));
  }

  Future<void> savePost(int postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/saved_posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'saved_post': {'user_id': 1},
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('No se pudo guardar la publicación');
    }
  }

  Future<List<SavedPost>> fetchSavedPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/users/1/saved_posts'));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las publicaciones guardadas');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((item) => SavedPost.fromJson(item)).toList();
  }

  Future<void> deleteSavedPost(int savedPostId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/saved_posts/$savedPostId'),
    );

    if (response.statusCode != 204) {
      throw Exception('No se pudo eliminar la publicación guardada');
    }
  }

  Future<List<Interest>> fetchInterests() async {
    final response = await http.get(Uri.parse('$baseUrl/interests'));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los intereses');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((item) => Interest.fromJson(item)).toList();
  }

  Future<List<Interest>> fetchUserInterests() async {
    final response = await http.get(Uri.parse('$baseUrl/users/1/interests'));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar tus intereses');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((item) => Interest.fromJson(item)).toList();
  }

  Future<void> updateUserInterests(List<int> interestIds) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/1/interests'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'interest_ids': interestIds}),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron actualizar los intereses');
    }
  }

  Future<List<Post>> fetchPersonalizedFeed() async {
    final response = await http.get(Uri.parse('$baseUrl/users/1/feed'));

    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar el feed personalizado');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((item) => Post.fromJson(item)).toList();
  }
}
