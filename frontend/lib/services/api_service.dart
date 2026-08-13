import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/community.dart';
import '../models/post.dart';

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
}