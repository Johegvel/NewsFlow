class Community {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String topic;
  final int postsCount;

  Community({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.topic,
    required this.postsCount,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      topic: json['topic'] ?? '',
      postsCount: json['posts_count'] ?? 0,
    );
  }
}