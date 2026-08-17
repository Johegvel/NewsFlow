import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.title,
    required super.content,
    super.postType,
    super.status,
    super.publishedAt,
    required super.userId,
    required super.userName,
    required super.communityId,
    required super.communityName,
    super.communitySlug,
    super.commentsCount = 0,
    super.reactionsCount = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    final communityJson = json['community'] as Map<String, dynamic>? ?? {};

    return PostModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      postType: json['post_type'] as String?,
      status: json['status'] as String?,
      publishedAt: json['published_at'] as String?,
      userId: userJson['id'] is int ? userJson['id'] : int.tryParse(userJson['id']?.toString() ?? '1') ?? 1,
      userName: userJson['name'] as String? ?? 'Usuario',
      communityId: communityJson['id'] is int ? communityJson['id'] : int.tryParse(communityJson['id']?.toString() ?? '1') ?? 1,
      communityName: communityJson['name'] as String? ?? 'General',
      communitySlug: communityJson['slug'] as String?,
      commentsCount: json['comments_count'] is int ? json['comments_count'] : 0,
      reactionsCount: json['reactions_count'] is int ? json['reactions_count'] : 0,
    );
  }
}
