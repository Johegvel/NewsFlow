import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flews_notification.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../domain/entities/comment_entity.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../service_locator.dart';
import '../create_critique/create_critique_page.dart';

class PostDetailPage extends StatefulWidget {
  final PostEntity post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController commentController = TextEditingController();

  late Future<List<CommentEntity>> commentsFuture;

  bool sendingComment = false;
  bool reacting = false;
  bool savingPost = false;

  int get currentUserId => ServiceLocator.authRepository.currentUser?.id ?? 1;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  void loadComments() {
    commentsFuture = ServiceLocator.postRepository.fetchComments(widget.post.id);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> sendComment() async {
    final text = commentController.text.trim();

    if (text.isEmpty) {
      FlewsNotificationHelper.show(
        context: context,
        title: 'Comentario vacío',
        message: 'Por favor escribe un mensaje antes de publicar.',
        actionIcon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() {
      sendingComment = true;
    });

    try {
      await ServiceLocator.postRepository.createComment(
        postId: widget.post.id,
        content: text,
        userId: currentUserId,
      );

      commentController.clear();

      setState(() {
        loadComments();
      });

      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Comentario publicado',
          message: 'Tu opinión ha sido añadida a la conversación.',
          actionIcon: Icons.chat_bubble_outline_rounded,
        );
      }
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Error al comentar',
          message: '$error',
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
    setState(() {
      reacting = true;
    });

    try {
      await ServiceLocator.postRepository.createReaction(
        postId: widget.post.id,
        userId: currentUserId,
      );

      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: '¡Reacción registrada!',
          message: 'Has indicado que esta noticia es relevante.',
          actionIcon: Icons.thumb_up_alt_rounded,
        );
      }
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Error de reacción',
          message: '$error',
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

  Future<void> reportPost() async {
    final reasonController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.borderColor),
          ),
          title: const Row(
            children: [
              Icon(Icons.flag_outlined, color: AppTheme.amberAccent),
              SizedBox(width: 8),
              Text('Reportar Noticia', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: TextField(
            controller: reasonController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Motivo del reporte (ej. desinformación, spam)...',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            FilledButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                Navigator.pop(dialogContext, reason.isNotEmpty ? reason : null);
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.amberAccent, foregroundColor: Colors.black),
              child: const Text('Enviar Reporte'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) return;

    try {
      await ServiceLocator.reportRepository.createReport(
        postId: widget.post.id,
        reason: result,
        userId: currentUserId,
      );

      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Reporte recibido',
          message: 'Gracias por colaborar con la calidad informativa de Flews.',
          actionIcon: Icons.verified_user_outlined,
        );
      }
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Error al reportar',
          message: '$error',
        );
      }
    }
  }

  Future<void> saveCurrentPost() async {
    setState(() {
      savingPost = true;
    });

    try {
      await ServiceLocator.postRepository.savePost(
        postId: widget.post.id,
        userId: currentUserId,
      );

      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Noticia guardada',
          message: 'Artículo añadido a tu lista de lectura guardada.',
          actionIcon: Icons.bookmark_added_rounded,
        );
      }
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Error al guardar',
          message: '$error',
        );
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
        title: const Text('Detalle de Noticia'),
        actions: [
          IconButton(
            onPressed: savingPost ? null : saveCurrentPost,
            icon: savingPost
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.amberAccent),
                  )
                : const Icon(Icons.bookmark_outline_rounded),
            tooltip: 'Guardar publicación',
          ),
          IconButton(
            onPressed: reportPost,
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Reportar publicación',
          ),
        ],
      ),
      body: Center(
        child: ResponsiveContainer(
          maxWidth: 850,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.groups_rounded, size: 16, color: AppTheme.amberAccent),
                        const SizedBox(width: 6),
                        Text(
                          post.communityName,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                post.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                post.content,
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 5),
                  Text(
                    'Publicado por ${post.userName}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: reacting ? null : sendReaction,
                    icon: reacting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.thumb_up_rounded, size: 18),
                    label: const Text('Relevante / Me gusta', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.amberAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateCritiquePage(quotedPost: post),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review_outlined, size: 18, color: AppTheme.amberAccent),
                    label: const Text('✍️ Escribir Crítica / Análisis', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.amberAccent, width: 1.2),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Divider(color: AppTheme.borderColor),
              const SizedBox(height: 16),
              Text(
                'Comentarios y Discusión',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Añade una perspectiva constructiva...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: sendingComment ? null : sendComment,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.amberAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: sendingComment
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('Enviar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<CommentEntity>>(
                future: commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.amberAccent),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFFEF4444))),
                    );
                  }

                  final comments = snapshot.data ?? [];

                  if (comments.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Aún no hay comentarios. ¡Sé el primero en aportar!',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppTheme.amberAccent,
                                  child: Text(
                                    comment.userName.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  comment.userName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              comment.content,
                              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    },
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
