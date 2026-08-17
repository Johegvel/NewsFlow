import '../../domain/entities/saved_post_entity.dart';
import 'post_model.dart';

class SavedPostModel extends SavedPostEntity {
  const SavedPostModel({
    required super.id,
    required super.userId,
    required super.postId,
    required super.post,
  });

  factory SavedPostModel.fromJson(Map<String, dynamic> json) {
    return SavedPostModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '1') ?? 1,
      postId: json['post_id'] is int ? json['post_id'] : int.tryParse(json['post_id']?.toString() ?? '0') ?? 0,
      post: PostModel.fromJson(json['post'] as Map<String, dynamic>? ?? {}),
    );
  }
}
