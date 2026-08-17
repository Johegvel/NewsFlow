class CommunityEntity {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? topic;

  const CommunityEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.topic,
  });
}
