import '../../domain/entities/report_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.postId,
    required super.postTitle,
    required super.userId,
    required super.userName,
    required super.reason,
    required super.status,
    super.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final postJson = json['post'] as Map<String, dynamic>? ?? {};
    final userJson = json['user'] as Map<String, dynamic>? ?? {};

    return ReportModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      postId: postJson['id'] is int ? postJson['id'] : int.tryParse(postJson['id']?.toString() ?? '0') ?? 0,
      postTitle: postJson['title'] as String? ?? 'Sin título',
      userId: userJson['id'] is int ? userJson['id'] : int.tryParse(userJson['id']?.toString() ?? '1') ?? 1,
      userName: userJson['name'] as String? ?? 'Usuario',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] as String?,
    );
  }
}
