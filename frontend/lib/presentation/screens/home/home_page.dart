import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/post_formatters.dart';
import '../../../core/widgets/flews_bottom_navigation.dart';
import '../../../core/widgets/flews_empty_state.dart';
import '../../../core/widgets/flews_section_switcher.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../domain/entities/community_entity.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../service_locator.dart';
import '../../widgets/critique_card.dart';
import '../../widgets/post_card.dart';
import '../post_detail/post_detail_page.dart';
import '../profile/profile_page.dart';
import '../saved_posts/saved_posts_page.dart';

class HomePage extends StatefulWidget {
  final int initialTab;

  const HomePage({super.key, this.initialTab = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Future<List<PostEntity>> newsFuture;
  late Future<List<PostEntity>> critiquesFuture;
  late Future<List<CommunityEntity>> communitiesFuture;

  String searchText = '';
  int? selectedCommunityId;
  String sortOption = 'recent'; // 'recent', 'score_desc', 'score_asc'

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(
          length: 2,
          initialIndex: widget.initialTab <= 0 ? 0 : 1,
          vsync: this,
        )..addListener(() {
          if (!_tabController.indexIsChanging && mounted) {
            setState(() {
              searchText = '';
              selectedCommunityId = null;
            });
          }
        });
    loadData();
  }

  void loadData() {
    newsFuture = ServiceLocator.postRepository.fetchPosts(
      filter: 'news',
      sortBy: sortOption,
    );
    critiquesFuture = ServiceLocator.postRepository.fetchPosts(
      filter: 'critiques',
      sortBy: sortOption,
    );
    communitiesFuture = ServiceLocator.communityRepository.fetchCommunities();
  }

  void _updateSortOption(String option) {
    if (sortOption == option) return;
    setState(() {
      sortOption = option;
      loadData();
    });
  }

  Future<void> refreshData() async {
    setState(loadData);
    await Future.wait<void>([
      newsFuture.then<void>((_) {}),
      critiquesFuture.then<void>((_) {}),
      communitiesFuture.then<void>((_) {}),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PostEntity> filterItems(List<PostEntity> items) {
    final query = searchText.trim().toLowerCase();
    final filtered = items.where((item) {
      final matchesSearch =
          query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.content.toLowerCase().contains(query);
      final matchesCommunity =
          selectedCommunityId == null ||
          item.communityId == selectedCommunityId;
      return matchesSearch && matchesCommunity;
    }).toList();

    if (sortOption == 'score_desc') {
      filtered.sort((a, b) => b.reactionsCount.compareTo(a.reactionsCount));
    } else if (sortOption == 'score_asc') {
      filtered.sort((a, b) => a.reactionsCount.compareTo(b.reactionsCount));
    } else {
      filtered.sort((a, b) {
        final dateA = a.publishedAt ?? '';
        final dateB = b.publishedAt ?? '';
        return dateB.compareTo(dateA);
      });
    }

    return filtered;
  }

  void _selectSection(int index) {
    if (_tabController.index == index) return;
    _tabController.animateTo(index);
  }

  Future<void> _onBottomSelected(int index) async {
    if (index < 2) {
      _selectSection(index);
      return;
    }
    if (index == 2) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const SavedPostsPage()),
      );
    } else {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
      );
    }
    if (mounted) refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ServiceLocator.authRepository.currentUser;
    final currentTab = _tabController.index;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 62,
        titleSpacing: 16,
        title: Image.asset(
          'assets/images/flews_logo.png',
          width: 62,
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.newspaper_rounded, color: AppTheme.amberAccent),
        ),
        actions: [
          IconButton(
            onPressed: () => _onBottomSelected(2),
            icon: const Icon(Icons.bookmark_border_rounded),
            tooltip: 'Publicaciones guardadas',
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _onBottomSelected(3),
            borderRadius: BorderRadius.circular(99),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppTheme.amberAccent,
              child: Text(
                initialsFor(currentUser?.name ?? 'Usuario'),
                style: const TextStyle(
                  color: AppTheme.darkBackground,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      bottomNavigationBar: FlewsBottomNavigation(
        selectedIndex: currentTab,
        onSelected: _onBottomSelected,
      ),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: RefreshIndicator(
          onRefresh: refreshData,
          color: AppTheme.amberAccent,
          backgroundColor: AppTheme.surfaceColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FlewsSectionSwitcher(
                        selectedIndex: currentTab,
                        onSelected: _selectSection,
                      ),
                      const SizedBox(height: 16),
                      if (currentTab == 0) ...[
                        TextField(
                          key: const ValueKey('news-search'),
                          decoration: const InputDecoration(
                            hintText:
                                'Buscar noticias por titular o contexto...',
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          onChanged: (value) =>
                              setState(() => searchText = value),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Text(
                              'ORDENAR POR',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            const Spacer(),
                            if (sortOption != 'recent')
                              GestureDetector(
                                onTap: () => _updateSortOption('recent'),
                                child: const Text(
                                  'Restablecer',
                                  style: TextStyle(
                                    color: AppTheme.amberAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _SortChip(
                                label: 'Más recientes',
                                icon: Icons.access_time_rounded,
                                isSelected: sortOption == 'recent',
                                onSelected: () => _updateSortOption('recent'),
                              ),
                              const SizedBox(width: 8),
                              _SortChip(
                                label: 'Mejor puntuadas',
                                icon: Icons.star_rounded,
                                isSelected: sortOption == 'score_desc',
                                onSelected: () =>
                                    _updateSortOption('score_desc'),
                              ),
                              const SizedBox(width: 8),
                              _SortChip(
                                label: 'Menor puntuadas',
                                icon: Icons.trending_down_rounded,
                                isSelected: sortOption == 'score_asc',
                                onSelected: () =>
                                    _updateSortOption('score_asc'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'EXPLORAR POR COMUNIDAD',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ] else
                        const Text(
                          'FILTRAR POR COMUNIDADES',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      const SizedBox(height: 9),
                      _CommunityFilters(
                        future: communitiesFuture,
                        selectedId: selectedCommunityId,
                        onSelected: (id) =>
                            setState(() => selectedCommunityId = id),
                      ),
                    ],
                  ),
                ),
              ),
              _buildFeed(currentTab),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeed(int currentTab) {
    return FutureBuilder<List<PostEntity>>(
      future: currentTab == 0 ? newsFuture : critiquesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.amberAccent),
            ),
          );
        }
        if (snapshot.hasError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FlewsEmptyState(
                icon: Icons.cloud_off_outlined,
                message: 'No pudimos consultar el servidor',
                detail: '${snapshot.error}'.replaceAll('Exception: ', ''),
              ),
            ),
          );
        }

        final items = filterItems(snapshot.data ?? const <PostEntity>[]);
        if (items.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FlewsEmptyState(
                icon: currentTab == 0
                    ? Icons.newspaper_outlined
                    : Icons.mic_none_rounded,
                message: currentTab == 0
                    ? 'No hay noticias con estos filtros.'
                    : 'Aún no hay críticas en esta comunidad.',
                detail: currentTab == 1
                    ? 'Abre una noticia y publica el primer análisis.'
                    : null,
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final postIndex = index ~/ 2;
              if (index.isOdd) return const SizedBox(height: 16);
              final item = items[postIndex];
              void onTap() {
                Navigator.of(context)
                    .push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => PostDetailPage(post: item),
                      ),
                    )
                    .then((_) {
                      if (mounted) refreshData();
                    });
              }

              return currentTab == 0
                  ? PostCard(post: item, onTap: onTap)
                  : CritiqueCard(critique: item, onTap: onTap);
            }, childCount: items.length * 2 - 1),
          ),
        );
      },
    );
  }
}

class _CommunityFilters extends StatelessWidget {
  final Future<List<CommunityEntity>> future;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  const _CommunityFilters({
    required this.future,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CommunityEntity>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator(
            color: AppTheme.amberAccent,
            backgroundColor: AppTheme.surfaceColor,
            minHeight: 2,
          );
        }
        if (snapshot.hasError) return const SizedBox.shrink();
        final communities = snapshot.data ?? const <CommunityEntity>[];

        return SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: communities.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final community = index == 0 ? null : communities[index - 1];
              final id = community?.id;
              final selected = selectedId == id;
              final label = community == null
                  ? 'Todas'
                  : '${communityEmoji(community.slug, community.name)} ${community.name}';

              return ChoiceChip(
                selected: selected,
                onSelected: (_) => onSelected(id),
                label: Text(label),
                showCheckmark: false,
                backgroundColor: AppTheme.surfaceColor,
                selectedColor: AppTheme.amberAccent,
                side: const BorderSide(color: AppTheme.borderColor, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                labelStyle: TextStyle(
                  color: selected ? AppTheme.darkBackground : AppTheme.bodyText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            },
          ),
        );
      },
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;

  const _SortChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.amberAccent.withValues(alpha: 0.15)
                : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.amberAccent : AppTheme.borderColor,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppTheme.amberAccent : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.amberAccent : AppTheme.bodyText,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
