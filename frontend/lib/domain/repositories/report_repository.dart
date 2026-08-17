import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<void> createReport({
    required int postId,
    required String reason,
    required int userId,
  });
  Future<List<ReportEntity>> fetchReports();
  Future<ReportEntity> updateReport(int reportId, String status);
}
