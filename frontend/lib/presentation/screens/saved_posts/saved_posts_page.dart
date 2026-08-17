import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flews_notification.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../domain/entities/saved_post_entity.dart';
import '../../../service_locator.dart';
import '../post_detail/post_detail_page.dart';

class SavedPostsPage extends StatefulWidget {
  const SavedPostsPage({super.key});

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  late Future<List<SavedPostEntity>> savedPostsFuture;

  int get currentUserId => ServiceLocator.authRepository.currentUser?.id ?? 1;

  @override
  void initState() {
    super.initState();
    loadSavedPosts();
  }

  void loadSavedPosts() {
    savedPostsFuture = ServiceLocator.postRepository.fetchSavedPosts(currentUserId);
  }

  Future<void> removeSavedPost(SavedPostEntity savedPost) async {
    try {
      await ServiceLocator.postRepository.deleteSavedPost(savedPost.id);

      setState(() {
        loadSavedPosts();
      });

      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Noticia eliminada',
          message: 'Se ha quitado la publicación de tu lista de guardados.',
          actionIcon: Icons.bookmark_remove_rounded,
        );
      }
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Error al eliminar',
          message: '$error',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones Guardadas'),
      ),
      body: FutureBuilder<List<SavedPostEntity>>(
        future: savedPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.amberAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFFEF4444)),
              ),
            );
          }

          final savedPosts = snapshot.data ?? [];

          if (savedPosts.isEmpty) {
            return const Center(
              child: Text(
                'No tienes publicaciones guardadas.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return Center(
            child: ResponsiveContainer(
              maxWidth: 850,
              child: ListView.builder(
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
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Text(
                        '${post.communityName}\n${post.content}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      isThreeLine: true,
                      leading: const Icon(Icons.bookmark, color: AppTheme.amberAccent),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
