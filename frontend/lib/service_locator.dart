import 'data/datasources/local_storage_datasource.dart';
import 'data/datasources/remote_api_datasource.dart';
import 'data/repositories_impl/auth_repository_impl.dart';
import 'data/repositories_impl/community_repository_impl.dart';
import 'data/repositories_impl/post_repository_impl.dart';
import 'data/repositories_impl/report_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/community_repository.dart';
import 'domain/repositories/post_repository.dart';
import 'domain/repositories/report_repository.dart';

class ServiceLocator {
  static late final RemoteApiDataSource remoteDataSource;
  static late final LocalStorageDataSource localDataSource;

  static late final AuthRepository authRepository;
  static late final PostRepository postRepository;
  static late final CommunityRepository communityRepository;
  static late final ReportRepository reportRepository;

  static void init() {
    remoteDataSource = RemoteApiDataSourceImpl();
    localDataSource = LocalStorageDataSourceImpl();

    authRepository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    postRepository = PostRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    communityRepository = CommunityRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    reportRepository = ReportRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
  }
}
