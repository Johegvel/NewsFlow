import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flews_app_bar_title.dart';
import '../../../core/widgets/flews_notification.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../domain/entities/community_entity.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../service_locator.dart';
import '../../widgets/critique_card.dart';
import '../../widgets/post_card.dart';
import '../auth/auth_screen.dart';
import '../moderation/moderation_page.dart';
import '../post_detail/post_detail_page.dart';
import '../saved_posts/saved_posts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late Future<List<PostEntity>> newsFuture;
  late Future<List<PostEntity>> critiquesFuture;
  late Future<List<CommunityEntity>> communitiesFuture;

  String searchText = '';
  int? selectedCommunityId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    loadData();
  }

  void loadData() {
    newsFuture = ServiceLocator.postRepository.fetchPosts(filter: 'news');
    critiquesFuture = ServiceLocator.postRepository.fetchPosts(filter: 'critiques');
    communitiesFuture = ServiceLocator.communityRepository.fetchCommunities();
  }

  Future<void> refreshData() async {
    setState(() {
      loadData();
    });

    await Future.wait([
      newsFuture,
      critiquesFuture,
      communitiesFuture,
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PostEntity> filterItems(List<PostEntity> items) {
    return items.where((item) {
      final matchesSearch =
          item.title.toLowerCase().contains(searchText.toLowerCase()) ||
          item.content.toLowerCase().contains(searchText.toLowerCase());

      final matchesCommunity = selectedCommunityId == null ||
          item.communityId == selectedCommunityId;

      return matchesSearch && matchesCommunity;
    }).toList();
  }

  Future<void> _logout() async {
    await ServiceLocator.authRepository.logout();
    if (!mounted) return;
    FlewsNotificationHelper.show(
      context: context,
      title: 'Sesión finalizada',
      message: 'Has cerrado sesión correctamente.',
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ServiceLocator.authRepository.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const FlewsAppBarTitle(showTagline: true),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SavedPostsPage(),
                ),
              );
            },
            icon: const Icon(Icons.bookmark_outline_rounded),
            tooltip: 'Publicaciones guardadas',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ModerationPage(),
                ),
              );
            },
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: 'Moderación',
          ),
          IconButton(
            onPressed: refreshData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
          ),
          const SizedBox(width: 4),

          // User Profile Menu
          PopupMenuButton<String>(
            tooltip: 'Perfil de usuario',
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppTheme.borderColor),
            ),
            color: AppTheme.surfaceColor,
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.amberAccent,
              child: Text(
                (currentUser?.name.isNotEmpty == true)
                    ? currentUser!.name.substring(0, 1).toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser?.name ?? 'Usuario',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      currentUser?.email ?? '',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Divider(color: AppTheme.borderColor, height: 16),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ResponsiveContainer(
          maxWidth: 1100,
          child: RefreshIndicator(
            onRefresh: refreshData,
            color: AppTheme.amberAccent,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dual Section Switcher: Noticias Curadas vs Críticas
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                              color: AppTheme.amberAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelColor: Colors.black,
                            unselectedLabelColor: AppTheme.textSecondary,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.newspaper_rounded, size: 18),
                                text: 'Noticias Curadas',
                              ),
                              Tab(
                                icon: Icon(Icons.rate_review_rounded, size: 18),
                                text: 'Críticas y Análisis',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Search Input
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: _tabController.index == 0
                                ? 'Buscar noticias por titular o contexto...'
                                : 'Buscar críticas por opinión o temática...',
                            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                            prefixIcon: const Icon(Icons.search, color: AppTheme.amberAccent),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        // Community Filter
                        FutureBuilder<List<CommunityEntity>>(
                          future: communitiesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const LinearProgressIndicator(
                                minHeight: 2,
                                color: AppTheme.amberAccent,
                                backgroundColor: AppTheme.surfaceColor,
                              );
                            }

                            if (snapshot.hasError) {
                              return const SizedBox.shrink();
                            }

                            final communities = snapshot.data ?? [];

                            return DropdownButtonFormField<int?>(
                              initialValue: selectedCommunityId,
                              dropdownColor: AppTheme.surfaceColor,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Filtrar por comunidad temática',
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Todas las comunidades'),
                                ),
                                ...communities.map(
                                  (community) => DropdownMenuItem<int?>(
                                    value: community.id,
                                    child: Text(community.name),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedCommunityId = value;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Content View (Tab 0: Curated News Feed, Tab 1: Community Critiques Feed)
                FutureBuilder<List<PostEntity>>(
                  future: _tabController.index == 0 ? newsFuture : critiquesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(color: AppTheme.amberAccent),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Error al consultar el servidor:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFFEF4444)),
                            ),
                          ),
                        ),
                      );
                    }

                    final items = filterItems(snapshot.data ?? []);

                    if (items.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _tabController.index == 0
                                    ? Icons.newspaper_rounded
                                    : Icons.rate_review_outlined,
                                size: 48,
                                color: AppTheme.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _tabController.index == 0
                                    ? 'No hay noticias en esta categoría.'
                                    : 'Aún no se han publicado críticas en esta comunidad.\n¡Sé el primero en analizar una noticia!',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = items[index];

                            if (_tabController.index == 0) {
                              // Tab 0: Curated News Card
                              return PostCard(
                                post: item,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PostDetailPage(
                                        post: item,
                                      ),
                                    ),
                                  ).then((_) => refreshData());
                                },
                              );
                            } else {
                              // Tab 1: Community Critique Card
                              return CritiqueCard(
                                critique: item,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PostDetailPage(
                                        post: item,
                                      ),
                                    ),
                                  ).then((_) => refreshData());
                                },
                              );
                            }
                          },
                          childCount: items.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 480,
                          mainAxisExtent: 230,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
