class PostEntity {
  final int id;
  final String title;
  final String content;
  final String? postType;
  final String? status;
  final String? publishedAt;
  final int userId;
  final String userName;
  final int communityId;
  final String communityName;
  final String? communitySlug;
  final int commentsCount;
  final int reactionsCount;
  final int? viewerReactionId;
  final int? viewerSavedPostId;

  const PostEntity({
    required this.id,
    required this.title,
    required this.content,
    this.postType,
    this.status,
    this.publishedAt,
    required this.userId,
    required this.userName,
    required this.communityId,
    required this.communityName,
    this.communitySlug,
    this.commentsCount = 0,
    this.reactionsCount = 0,
    this.viewerReactionId,
    this.viewerSavedPostId,
  });

  bool get isLikedByViewer => viewerReactionId != null;
  bool get isSavedByViewer => viewerSavedPostId != null;
}
