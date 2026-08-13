class Report {
  final int id;
  final String reason;
  final String status;
  final int postId;
  final String postTitle;
  final String userName;

  Report({
    required this.id,
    required this.reason,
    required this.status,
    required this.postId,
    required this.postTitle,
    required this.userName,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    final post = json['post'] as Map<String, dynamic>;
    final user = json['user'] as Map<String, dynamic>;

    return Report(
      id: json['id'],
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      postId: post['id'],
      postTitle: post['title'] ?? '',
      userName: user['name'] ?? '',
    );
  }
}