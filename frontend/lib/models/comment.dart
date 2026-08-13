class Comment {
  final int id;
  final String content;
  final String userName;
  final DateTime? createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.userName,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;

    return Comment(
      id: json['id'],
      content: json['content'] ?? '',
      userName: user['name'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}