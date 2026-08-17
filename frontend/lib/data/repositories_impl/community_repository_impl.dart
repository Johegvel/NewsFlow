import '../../domain/entities/community_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/remote_api_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final RemoteApiDataSource remoteDataSource;

  CommunityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CommunityEntity>> fetchCommunities() async {
    return await remoteDataSource.fetchCommunities();
  }
}
