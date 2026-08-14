import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../models/reaction.dart';
import '../models/reaction.dart';
import '../models/saved_post.dart';
import '../services/auth_service.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final ApiService apiService = ApiService();
  final TextEditingController commentController = TextEditingController();

  late Future<List<Comment>> commentsFuture;
  bool sendingComment = false;
  bool reacting = false;
  bool savingPost = false;
  bool hasReacted = false;
  int? reactionId;

  bool isSaved = false;
  int? savedPostId;

  @override
  void initState() {
    super.initState();
    commentsFuture = apiService.fetchComments(widget.post.id);

    _loadInteractionState();
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
          const SnackBar(content: Text('Comentario publicado correctamente')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          sendingComment = false;
        });
      }
    }
  }

  Future<void> _loadInteractionState() async {
    try {
      final savedPosts = await apiService.fetchSavedPosts();
      final reactions = await apiService.fetchReactions(widget.post.id);
      final userId = await AuthService.getUserId();

      SavedPost? savedPost;

      for (final item in savedPosts) {
        if (item.post.id == widget.post.id) {
          savedPost = item;
          break;
        }
      }

      Reaction? myReaction;

      for (final reaction in reactions) {
        if (reaction.userId == userId) {
          myReaction = reaction;
          break;
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        isSaved = savedPost != null;
        savedPostId = savedPost?.id;

        hasReacted = myReaction != null;
        reactionId = myReaction?.id;
      });
    } catch (_) {
      // La publicación puede seguir cargando aunque falle esta consulta.
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
      if (hasReacted) {
        final id = reactionId;

        if (id == null) {
          throw Exception('No se encontró la reacción');
        }

        await apiService.deleteReaction(id);

        if (mounted) {
          setState(() {
            hasReacted = false;
            reactionId = null;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Reacción eliminada')));
        }
      } else {
        final Reaction reaction = await apiService.createReaction(
          widget.post.id,
        );

        if (mounted) {
          setState(() {
            hasReacted = true;
            reactionId = reaction.id;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Reacción registrada')));
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          reacting = false;
        });
      }
    }
  }

  Future<void> reportPost() async {
    final controller = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reportar publicación'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Indica el motivo del reporte',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || reason == null || reason.isEmpty) {
      return;
    }

    try {
      await apiService.createReport(widget.post.id, reason);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte enviado correctamente')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  Future<void> saveCurrentPost() async {
    if (savingPost) {
      return;
    }

    setState(() {
      savingPost = true;
    });

    try {
      if (isSaved) {
        final id = savedPostId;

        if (id == null) {
          throw Exception('No se encontró el guardado');
        }

        await apiService.deleteSavedPost(id);

        if (mounted) {
          setState(() {
            isSaved = false;
            savedPostId = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publicación retirada de guardados')),
          );
        }
      } else {
        final int id = await apiService.savePost(widget.post.id);

        if (mounted) {
          setState(() {
            isSaved = true;
            savedPostId = id;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publicación guardada correctamente')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          savingPost = false;
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
        actions: [
          IconButton(
            onPressed: savingPost ? null : saveCurrentPost,
            icon: savingPost
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
            color: isSaved ? Theme.of(context).colorScheme.primary : null,
            tooltip: isSaved
                ? 'Quitar de publicaciones guardadas'
                : 'Guardar publicación',
          ),
          IconButton(
            onPressed: reportPost,
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Reportar publicación',
          ),
        ],
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
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
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
                    icon: Icon(
                      hasReacted ? Icons.thumb_up : Icons.thumb_up_outlined,
                    ),
                    label: Text(hasReacted ? 'Te gusta' : 'Me gusta'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Comentarios',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
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
                            child: CircularProgressIndicator(strokeWidth: 2),
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
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error al cargar comentarios: ${snapshot.error}',
                    );
                  }

                  final comments = snapshot.data ?? [];

                  if (comments.isEmpty) {
                    return const Text('Todavía no existen comentarios.');
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
