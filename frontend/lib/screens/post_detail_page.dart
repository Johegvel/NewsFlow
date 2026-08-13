import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final ApiService apiService = ApiService();
  final TextEditingController commentController = TextEditingController();

  late Future<List<Comment>> commentsFuture;
  bool sendingComment = false;
  bool reacting = false;

  @override
  void initState() {
    super.initState();
    commentsFuture = apiService.fetchComments(widget.post.id);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> sendComment() async {
    final content = commentController.text.trim();

    if (content.isEmpty) {
      return;
    }

    setState(() {
      sendingComment = true;
    });

    try {
      await apiService.createComment(widget.post.id, content);

      commentController.clear();

      setState(() {
        commentsFuture = apiService.fetchComments(widget.post.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentario publicado correctamente'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          sendingComment = false;
        });
      }
    }
  }

  Future<void> sendReaction() async {
    if (reacting) {
      return;
    }

    setState(() {
      reacting = true;
    });

    try {
      await apiService.createReaction(widget.post.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reacción registrada'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          reacting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de publicación'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Chip(
                label: Text(post.communityName),
                avatar: const Icon(Icons.groups, size: 18),
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                post.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Publicado por ${post.userName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: reacting ? null : sendReaction,
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('Me gusta'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Comentarios',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un comentario...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: sendingComment ? null : sendComment,
                    icon: sendingComment
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Comment>>(
                future: commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error al cargar comentarios: ${snapshot.error}',
                    );
                  }

                  final comments = snapshot.data ?? [];

                  if (comments.isEmpty) {
                    return const Text(
                      'Todavía no existen comentarios.',
                    );
                  }

                  return Column(
                    children: comments.map((comment) {
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(comment.userName),
                          subtitle: Text(comment.content),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}