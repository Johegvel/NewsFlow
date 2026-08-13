import 'post.dart';

class SavedPost {
  final int id;
  final DateTime? createdAt;
  final Post post;

  SavedPost({
    required this.id,
    required this.createdAt,
    required this.post,
  });

  factory SavedPost.fromJson(Map<String, dynamic> json) {
    return SavedPost(
      id: json['id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      post: Post.fromJson(json['post']),
    );
  }
}