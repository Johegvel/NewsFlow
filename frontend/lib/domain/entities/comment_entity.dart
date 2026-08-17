class CommentEntity {
  final int id;
  final String content;
  final String? createdAt;
  final int userId;
  final String userName;
  final int postId;

  const CommentEntity({
    required this.id,
    required this.content,
    this.createdAt,
    required this.userId,
    required this.userName,
    required this.postId,
  });
}
