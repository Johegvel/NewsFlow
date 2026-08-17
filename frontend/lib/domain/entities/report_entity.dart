class ReportEntity {
  final int id;
  final int postId;
  final String postTitle;
  final int userId;
  final String userName;
  final String reason;
  final String status;
  final String? createdAt;

  const ReportEntity({
    required this.id,
    required this.postId,
    required this.postTitle,
    required this.userId,
    required this.userName,
    required this.reason,
    required this.status,
    this.createdAt,
  });
}
