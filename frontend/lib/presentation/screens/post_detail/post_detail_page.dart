import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/post_formatters.dart';
import '../../../core/widgets/flews_bottom_navigation.dart';
import '../../../core/widgets/flews_empty_state.dart';
import '../../../core/widgets/flews_notification.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../domain/entities/comment_entity.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../service_locator.dart';
import '../create_critique/create_critique_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';
import '../saved_posts/saved_posts_page.dart';

class PostDetailPage extends StatefulWidget {
  final PostEntity post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final commentController = TextEditingController();
  late Future<List<CommentEntity>> commentsFuture;
  bool sendingComment = false;
  bool reacting = false;
  bool savingPost = false;
  late PostEntity post;
  int? reactionId;
  int? savedPostId;
  int reactionsCount = 0;

  int get currentUserId => ServiceLocator.authRepository.currentUser?.id ?? 1;
  bool get isCritique => post.postType == 'critique';
  bool get isLiked => reactionId != null;
  bool get isSaved => savedPostId != null;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    reactionId = post.viewerReactionId;
    savedPostId = post.viewerSavedPostId;
    reactionsCount = post.reactionsCount;
    loadComments();
    unawaited(_refreshViewerState());
    if (!isCritique) unawaited(_registerRead());
  }

  void loadComments() {
    commentsFuture = ServiceLocator.postRepository.fetchComments(post.id);
  }

  Future<void> _refreshViewerState() async {
    try {
      final refreshed = await ServiceLocator.postRepository.fetchPost(post.id);
      if (!mounted) return;
      setState(() {
        post = refreshed;
        reactionId = refreshed.viewerReactionId;
        savedPostId = refreshed.viewerSavedPostId;
        reactionsCount = refreshed.reactionsCount;
      });
    } catch (_) {
      // La publicación recibida permite mantener la pantalla utilizable sin red.
    }
  }

  Future<void> _registerRead() async {
    try {
      await ServiceLocator.postRepository.markPostRead(post.id);
    } catch (_) {
      // Registrar la lectura no debe impedir que el usuario lea el artículo.
    }
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
        message: 'Escribe un mensaje antes de publicar.',
        actionIcon: Icons.warning_amber_rounded,
      );
      return;
    }
    setState(() => sendingComment = true);
    try {
      await ServiceLocator.postRepository.createComment(
        postId: post.id,
        content: text,
        userId: currentUserId,
      );
      if (!mounted) return;
      commentController.clear();
      setState(loadComments);
      FlewsNotificationHelper.show(
        context: context,
        title: 'Comentario publicado',
        message: 'Tu perspectiva se añadió a la conversación.',
        actionIcon: Icons.chat_bubble_outline_rounded,
      );
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'No pudimos comentar',
          message: '$error'.replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => sendingComment = false);
    }
  }

  Future<void> toggleReaction() async {
    setState(() => reacting = true);
    try {
      final wasLiked = isLiked;
      if (wasLiked) {
        await ServiceLocator.postRepository.deleteReaction(reactionId!);
      } else {
        reactionId = await ServiceLocator.postRepository.createReaction(
          postId: post.id,
          userId: currentUserId,
        );
      }
      if (mounted) {
        setState(() {
          if (wasLiked) reactionId = null;
          reactionsCount = wasLiked
              ? (reactionsCount - 1).clamp(0, 1 << 31)
              : reactionsCount + 1;
        });
        FlewsNotificationHelper.show(
          context: context,
          title: wasLiked ? 'Reacción eliminada' : 'Marcada como relevante',
          message: wasLiked
              ? 'Ya no aparece marcada como relevante.'
              : 'Tu reacción ayuda a priorizar información de calidad.',
          actionIcon: wasLiked
              ? Icons.thumb_up_off_alt_rounded
              : Icons.thumb_up_alt_rounded,
        );
      }
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'No pudimos registrar la reacción',
          message: '$error'.replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => reacting = false);
    }
  }

  Future<void> toggleSavedPost() async {
    setState(() => savingPost = true);
    try {
      final wasSaved = isSaved;
      if (wasSaved) {
        await ServiceLocator.postRepository.deleteSavedPost(
          savedPostId ?? 0,
          postId: post.id,
        );
      } else {
        final saved = await ServiceLocator.postRepository.savePost(
          postId: post.id,
          userId: currentUserId,
        );
        savedPostId = saved.id;
      }
      if (mounted) {
        setState(() {
          if (wasSaved) savedPostId = null;
        });
        FlewsNotificationHelper.show(
          context: context,
          title: wasSaved ? 'Eliminada de guardados' : 'Noticia guardada',
          message: wasSaved
              ? 'La publicación salió de tu lista de guardados.'
              : 'Publicación guardada de forma atemporal en tu cuenta.',
          actionIcon: wasSaved
              ? Icons.bookmark_remove_rounded
              : Icons.bookmark_added_rounded,
        );
      }
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'No pudimos procesar el guardado',
          message: '$error'.replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => savingPost = false);
    }
  }

  Future<void> reportPost() async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderColor),
        ),
        title: const Text('Reportar publicación'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Describe el motivo del reporte...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = reasonController.text.trim();
              Navigator.of(dialogContext).pop(value.isEmpty ? null : value);
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (reason == null || reason.isEmpty) return;

    try {
      await ServiceLocator.reportRepository.createReport(
        postId: widget.post.id,
        reason: reason,
        userId: currentUserId,
      );
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Reporte recibido',
          message: 'Gracias por ayudarnos a cuidar la calidad de Flews.',
          actionIcon: Icons.verified_user_outlined,
        );
      }
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'No pudimos enviar el reporte',
          message: '$error'.replaceAll('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _openCritiqueComposer() async {
    final published = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateCritiquePage(quotedPost: widget.post),
      ),
    );
    if (published == true && mounted) {
      FlewsNotificationHelper.show(
        context: context,
        title: '¡Crítica publicada con éxito!',
        message:
            'Tu análisis ya está disponible para toda la comunidad en la Tribuna.',
        actionIcon: Icons.check_circle_rounded,
      );
    }
  }

  void _openTopLevel(Widget page) {
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (_) => page),
      (_) => false,
    );
  }

  void _onBottomSelected(int index) {
    if (index == 0) _openTopLevel(const HomePage());
    if (index == 1) _openTopLevel(const HomePage(initialTab: 1));
    if (index == 2) _openTopLevel(const SavedPostsPage());
    if (index == 3) _openTopLevel(const ProfilePage());
  }

  @override
  Widget build(BuildContext context) {
    final post = this.post;
    final postMetadata = parsePostContent(post.content);
    final critiqueMetadata = parseCritiqueContent(post.content);
    final body = isCritique ? critiqueMetadata.body : postMetadata.body;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Volver',
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfaceColor,
              side: const BorderSide(color: AppTheme.borderColor),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
        ),
        actions: [
          IconButton(
            onPressed: savingPost ? null : toggleSavedPost,
            tooltip: isSaved
                ? 'Eliminar de publicaciones guardadas'
                : 'Guardar publicación',
            style: IconButton.styleFrom(
              backgroundColor: isSaved
                  ? AppTheme.amberAccent.withValues(alpha: 0.14)
                  : AppTheme.surfaceColor,
              side: BorderSide(
                color: isSaved ? AppTheme.amberAccent : AppTheme.borderColor,
              ),
            ),
            icon: savingPost
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.amberAccent,
                    ),
                  )
                : Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isSaved
                        ? AppTheme.amberAccent
                        : AppTheme.textPrimary,
                    size: 20,
                  ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            color: AppTheme.surfaceColor,
            onSelected: (value) {
              if (value == 'report') reportPost();
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      color: AppTheme.destructive,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Text('Reportar publicación'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: FlewsBottomNavigation(
        selectedIndex: isCritique ? 1 : 0,
        onSelected: _onBottomSelected,
      ),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              isCritique ? 'ANÁLISIS DE LA COMUNIDAD' : 'ARTÍCULO CURADO',
              style: const TextStyle(
                color: AppTheme.amberAccent,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaBadge(
                  label:
                      '${communityEmoji(post.communitySlug, post.communityName)} ${post.communityName}',
                ),
                if (isCritique)
                  _MetaBadge(
                    label: '⚖️ ${critiqueMetadata.stance}',
                    amber: true,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              post.title,
              style: AppTheme.editorial(fontSize: 32, height: 1.08),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: AppTheme.borderColor,
                  child: Text(
                    initialsFor(post.userName),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 9,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    post.userName,
                    style: const TextStyle(
                      color: AppTheme.bodyText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  formatRelativeDate(post.publishedAt),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            if (isCritique && critiqueMetadata.quotedTitle != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.amberAccent.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.newspaper_rounded,
                          color: AppTheme.amberAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'NOTICIA CITADA EN ESTE ANÁLISIS',
                          style: TextStyle(
                            color: AppTheme.amberAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Spacer(),
                        if (critiqueMetadata.quotedCommunity != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.darkBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              critiqueMetadata.quotedCommunity!,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      critiqueMetadata.quotedTitle!,
                      style: AppTheme.editorial(fontSize: 20, height: 1.18),
                    ),
                    if (critiqueMetadata.quotedPostId != null) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () async {
                          try {
                            final quotedPost =
                                await ServiceLocator.postRepository.fetchPost(
                              critiqueMetadata.quotedPostId!,
                            );
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PostDetailPage(post: quotedPost),
                                ),
                              );
                            }
                          } catch (_) {
                            if (context.mounted) {
                              FlewsNotificationHelper.show(
                                context: context,
                                title: 'Noticia no disponible',
                                message:
                                    'La noticia original superó el ciclo de 24 horas y expiró.',
                                actionIcon: Icons.timer_off_outlined,
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Leer noticia original completa',
                                style: TextStyle(
                                  color: AppTheme.amberAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: AppTheme.amberAccent,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            Text(
              body,
              style: const TextStyle(
                color: AppTheme.bodyText,
                fontSize: 15,
                height: 1.65,
              ),
            ),
            if (!isCritique) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.amberAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: AppTheme.amberAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TRANSPARENCIA EDITORIAL',
                            style: TextStyle(
                              color: AppTheme.amberAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fuente: ${postMetadata.source ?? 'Curaduría Flews'}'
                            '${postMetadata.relevance == null ? '' : ' • Relevancia ${postMetadata.relevance}'}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: reacting ? null : toggleReaction,
                    style: FilledButton.styleFrom(
                      backgroundColor: isLiked
                          ? AppTheme.amberAccent
                          : AppTheme.surfaceColor,
                      foregroundColor: isLiked
                          ? AppTheme.darkBackground
                          : AppTheme.bodyText,
                      side: BorderSide(
                        color: isLiked
                            ? AppTheme.amberAccent
                            : AppTheme.borderColor,
                      ),
                    ),
                    icon: reacting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.darkBackground,
                            ),
                          )
                        : Icon(
                            isLiked
                                ? Icons.thumb_up_alt_rounded
                                : Icons.thumb_up_alt_outlined,
                            size: 18,
                          ),
                    label: Text(
                      reactionsCount == 0
                          ? 'Relevante'
                          : 'Relevante · $reactionsCount',
                    ),
                  ),
                ),
                if (!isCritique) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openCritiqueComposer,
                      icon: const Icon(
                        Icons.edit_note_rounded,
                        color: AppTheme.amberAccent,
                        size: 20,
                      ),
                      label: const Text('Escribir Crítica'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.amberAccent),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Text(
                  isCritique ? 'Conversación' : 'Comentarios y discusión',
                  style: AppTheme.editorial(fontSize: 24),
                ),
                const Spacer(),
                Text(
                  '${post.commentsCount}',
                  style: const TextStyle(
                    color: AppTheme.amberAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Añade una perspectiva constructiva...',
                suffixIcon: IconButton(
                  onPressed: sendingComment ? null : sendComment,
                  tooltip: 'Publicar comentario',
                  icon: sendingComment
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.amberAccent,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: AppTheme.amberAccent,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FutureBuilder<List<CommentEntity>>(
              future: commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.amberAccent,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return FlewsEmptyState(
                    icon: Icons.cloud_off_outlined,
                    message: 'No pudimos cargar la conversación',
                    detail: '${snapshot.error}'.replaceAll('Exception: ', ''),
                  );
                }
                final comments = snapshot.data ?? const <CommentEntity>[];
                if (comments.isEmpty) {
                  return const FlewsEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    message: 'Aún no hay comentarios',
                    detail: 'Sé la primera persona en aportar una perspectiva.',
                  );
                }
                return Column(
                  children: comments
                      .map((comment) => _CommentCard(comment: comment))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;
  final bool amber;

  const _MetaBadge({required this.label, this.amber = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: amber ? AppTheme.amberAccent : AppTheme.borderColor,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: amber ? AppTheme.amberAccent : AppTheme.bodyText,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final CommentEntity comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                radius: 13,
                backgroundColor: AppTheme.borderColor,
                child: Text(
                  initialsFor(comment.userName),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 9,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comment.userName,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            comment.content,
            style: const TextStyle(
              color: AppTheme.bodyText,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
