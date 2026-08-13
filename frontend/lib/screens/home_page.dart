import 'package:flutter/material.dart';

import 'post_detail_page.dart';
import 'create_post_page.dart';
import 'moderation_page.dart';
import 'saved_posts_page.dart';
import '../models/community.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();

  late Future<List<Post>> postsFuture;
  late Future<List<Community>> communitiesFuture;

  String searchText = '';
  int? selectedCommunityId;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    postsFuture = apiService.fetchPosts();
    communitiesFuture = apiService.fetchCommunities();
  }

  Future<void> refreshData() async {
    setState(() {
      loadData();
    });

    await Future.wait([
      postsFuture,
      communitiesFuture,
    ]);
  }

  List<Post> filterPosts(List<Post> posts) {
    return posts.where((post) {
      final matchesSearch =
          post.title.toLowerCase().contains(searchText.toLowerCase()) ||
          post.content.toLowerCase().contains(searchText.toLowerCase());

      final matchesCommunity = selectedCommunityId == null ||
          post.communityId == selectedCommunityId;

      return matchesSearch && matchesCommunity;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NewsFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
            icon: const Icon(Icons.bookmark),
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
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Moderación',
          ),
          IconButton(
            onPressed: () async {
              final communities = await communitiesFuture;

              if (!context.mounted) return;

              final created = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatePostPage(
                    communities: communities,
                  ),
                ),
              );

              if (created == true) {
                setState(() {
                  loadData();
                });
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'Nueva publicación',
          ),
          IconButton(
            onPressed: refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu feed de noticias',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar publicaciones...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Community>>(
                      future: communitiesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return const Text(
                            'No se pudieron cargar los filtros.',
                          );
                        }

                        final communities = snapshot.data ?? [];

                        return DropdownButtonFormField<int?>(
                          value: selectedCommunityId,
                          decoration: InputDecoration(
                            labelText: 'Filtrar por comunidad',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
            FutureBuilder<List<Post>>(
              future: postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
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
                        ),
                      ),
                    ),
                  );
                }

                final posts = filterPosts(snapshot.data ?? []);

                if (posts.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('No existen publicaciones.'),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return PostCard(
                          post: posts[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PostDetailPage(
                                  post: posts[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: posts.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 420,
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
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child:InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                label: Text(post.communityName),
                avatar: const Icon(Icons.groups, size: 16),
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Publicado por ${post.userName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      )
    );
  }
}