import '../entities/community_entity.dart';

abstract class CommunityRepository {
  Future<List<CommunityEntity>> fetchCommunities();
}
