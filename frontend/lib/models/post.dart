class Post {
  final int id;
  final String title;
  final String content;
  final String postType;
  final String status;
  final DateTime? publishedAt;
  final int userId;
  final String userName;
  final int communityId;
  final String communityName;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.postType,
    required this.status,
    required this.publishedAt,
    required this.userId,
    required this.userName,
    required this.communityId,
    required this.communityName,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final community = json['community'] as Map<String, dynamic>;

    return Post(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      postType: json['post_type'] ?? '',
      status: json['status'] ?? '',
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'])
          : null,
      userId: user['id'],
      userName: user['name'] ?? '',
      communityId: community['id'],
      communityName: community['name'] ?? '',
    );
  }
}