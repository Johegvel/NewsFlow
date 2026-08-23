import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/post_formatters.dart';
import '../../../core/widgets/flews_bottom_navigation.dart';
import '../../../core/widgets/flews_empty_state.dart';
import '../../../core/widgets/flews_notification.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../domain/entities/saved_post_entity.dart';
import '../../../service_locator.dart';
import '../home/home_page.dart';
import '../post_detail/post_detail_page.dart';
import '../profile/profile_page.dart';

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
    savedPostsFuture = ServiceLocator.postRepository.fetchSavedPosts(
      currentUserId,
    );
  }

  Future<void> removeSavedPost(SavedPostEntity savedPost) async {
    try {
      await ServiceLocator.postRepository.deleteSavedPost(savedPost.id);
      if (!mounted) return;
      setState(loadSavedPosts);
      FlewsNotificationHelper.show(
        context: context,
        title: 'Noticia eliminada',
        message: 'Se quitó la publicación de tu lista de guardados.',
        actionIcon: Icons.bookmark_remove_rounded,
      );
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'No pudimos eliminarla',
          message: '$error'.replaceAll('Exception: ', ''),
        );
      }
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
    if (index == 3) _openTopLevel(const ProfilePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FlewsBottomNavigation(
        selectedIndex: 2,
        onSelected: _onBottomSelected,
      ),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<SavedPostEntity>>(
          future: savedPostsFuture,
          builder: (context, snapshot) {
            final savedPosts = snapshot.data ?? const <SavedPostEntity>[];
            return ResponsiveContainer(
              maxWidth: 720,
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(loadSavedPosts);
                  await savedPostsFuture;
                },
                color: AppTheme.amberAccent,
                backgroundColor: AppTheme.surfaceColor,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Publicaciones Guardadas',
                            style: AppTheme.editorial(fontSize: 32),
                          ),
                        ),
                        if (snapshot.connectionState != ConnectionState.waiting)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.amberAccent.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${savedPosts.length} ${savedPosts.length == 1 ? 'Item' : 'Items'}',
                              style: const TextStyle(
                                color: AppTheme.amberAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.only(top: 120),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.amberAccent,
                          ),
                        ),
                      )
                    else if (snapshot.hasError)
                      FlewsEmptyState(
                        icon: Icons.cloud_off_outlined,
                        message: 'No pudimos cargar tus guardados',
                        detail: '${snapshot.error}'.replaceAll(
                          'Exception: ',
                          '',
                        ),
                      )
                    else if (savedPosts.isEmpty)
                      const FlewsEmptyState(
                        icon: Icons.bookmark_border_rounded,
                        message: 'Aún no tienes noticias guardadas',
                        detail:
                            'Usa el marcador de una noticia para verla aquí.',
                      )
                    else
                      for (
                        var index = 0;
                        index < savedPosts.length;
                        index++
                      ) ...[
                        _SavedCard(
                          savedPost: savedPosts[index],
                          onRemove: () => removeSavedPost(savedPosts[index]),
                          onOpen: () async {
                            await Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => PostDetailPage(
                                  post: savedPosts[index].post,
                                ),
                              ),
                            );
                            if (mounted) setState(loadSavedPosts);
                          },
                        ),
                        if (index != savedPosts.length - 1)
                          const SizedBox(height: 16),
                      ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final SavedPostEntity savedPost;
  final VoidCallback onRemove;
  final VoidCallback onOpen;

  const _SavedCard({
    required this.savedPost,
    required this.onRemove,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final post = savedPost.post;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.darkBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${communityEmoji(post.communitySlug, post.communityName)} ${post.communityName}',
                        style: const TextStyle(
                          color: AppTheme.bodyText,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        onPressed: onRemove,
                        padding: EdgeInsets.zero,
                        tooltip: 'Eliminar de guardados',
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.darkBackground,
                          side: const BorderSide(color: AppTheme.borderColor),
                        ),
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: AppTheme.destructive,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  post.title,
                  style: AppTheme.editorial(fontSize: 22, height: 1.16),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text(
                      'Guardado recientemente',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Leer ahora',
                      style: TextStyle(
                        color: AppTheme.amberAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.amberAccent,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
