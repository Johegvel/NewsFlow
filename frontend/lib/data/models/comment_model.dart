import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.content,
    super.createdAt,
    required super.userId,
    required super.userName,
    required super.postId,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};

    return CommentModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      userId: userJson['id'] is int ? userJson['id'] : int.tryParse(userJson['id']?.toString() ?? '1') ?? 1,
      userName: userJson['name'] as String? ?? 'Usuario',
      postId: json['post_id'] is int ? json['post_id'] : int.tryParse(json['post_id']?.toString() ?? '0') ?? 0,
    );
  }
}
