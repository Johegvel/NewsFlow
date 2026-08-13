import 'package:flutter/material.dart';

import '../models/saved_post.dart';
import '../services/api_service.dart';
import 'post_detail_page.dart';

class SavedPostsPage extends StatefulWidget {
  const SavedPostsPage({super.key});

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  final ApiService apiService = ApiService();
  late Future<List<SavedPost>> savedPostsFuture;

  @override
  void initState() {
    super.initState();
    loadSavedPosts();
  }

  void loadSavedPosts() {
    savedPostsFuture = apiService.fetchSavedPosts();
  }

  Future<void> removeSavedPost(SavedPost savedPost) async {
    try {
      await apiService.deleteSavedPost(savedPost.id);

      setState(() {
        loadSavedPosts();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicación eliminada de guardados'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones guardadas'),
      ),
      body: FutureBuilder<List<SavedPost>>(
        future: savedPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final savedPosts = snapshot.data ?? [];

          if (savedPosts.isEmpty) {
            return const Center(
              child: Text('No tienes publicaciones guardadas.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: savedPosts.length,
            itemBuilder: (context, index) {
              final savedPost = savedPosts[index];
              final post = savedPost.post;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${post.communityName}\n${post.content}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  leading: const Icon(Icons.bookmark),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Eliminar de guardados',
                    onPressed: () => removeSavedPost(savedPost),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailPage(post: post),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}