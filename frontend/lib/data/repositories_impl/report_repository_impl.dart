import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/remote_api_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final RemoteApiDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createReport({
    required int postId,
    required String reason,
    required int userId,
  }) async {
    await remoteDataSource.createReport(
      postId: postId,
      reason: reason,
      userId: userId,
    );
  }

  @override
  Future<List<ReportEntity>> fetchReports() async {
    return await remoteDataSource.fetchReports();
  }

  @override
  Future<ReportEntity> updateReport(int reportId, String status) async {
    return await remoteDataSource.updateReport(reportId, status);
  }
}
