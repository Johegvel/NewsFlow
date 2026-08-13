import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/community.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/reaction.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000/api/v1';

  Future<List<Community>> fetchCommunities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/communities'),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las comunidades');
    }

    final data = jsonDecode(response.body) as List;

    return data
        .map((item) => Community.fromJson(item))
        .toList();
  }

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las publicaciones');
    }

    final data = jsonDecode(response.body) as List;

    return data
        .map((item) => Post.fromJson(item))
        .toList();
  }

  Future<Post> fetchPost(int postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId'),
    );

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

    return data
        .map((item) => Comment.fromJson(item))
        .toList();
  }

  Future<Comment> createComment(
    int postId,
    String content,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'comment': {
          'user_id': 1,
          'content': content,
        },
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
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'reaction': {
          'user_id': 1,
          'kind': 'like',
        },
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
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'post': {
          'user_id': 1,
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
}