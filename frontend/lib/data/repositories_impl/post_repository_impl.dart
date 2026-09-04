import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/saved_post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/remote_api_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final RemoteApiDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PostEntity>> fetchPosts({
    int? communityId,
    String? filter,
    String? sortBy,
  }) async {
    return await remoteDataSource.fetchPosts(
      communityId: communityId,
      filter: filter,
      sortBy: sortBy,
    );
  }

  @override
  Future<PostEntity> fetchPost(int postId) async {
    return await remoteDataSource.fetchPost(postId);
  }

  @override
  Future<PostEntity> createPost({
    required int communityId,
    required String title,
    required String content,
    required String postType,
    required int userId,
  }) async {
    return await remoteDataSource.createPost(
      communityId: communityId,
      title: title,
      content: content,
      postType: postType,
      userId: userId,
    );
  }

  @override
  Future<List<CommentEntity>> fetchComments(int postId) async {
    return await remoteDataSource.fetchComments(postId);
  }

  @override
  Future<CommentEntity> createComment({
    required int postId,
    required String content,
    required int userId,
  }) async {
    return await remoteDataSource.createComment(
      postId: postId,
      content: content,
      userId: userId,
    );
  }

  @override
  Future<int> createReaction({required int postId, required int userId}) {
    return remoteDataSource.createReaction(postId: postId, userId: userId);
  }

  @override
  Future<void> deleteReaction(int reactionId) {
    return remoteDataSource.deleteReaction(reactionId);
  }

  @override
  Future<SavedPostEntity> savePost({required int postId, required int userId}) {
    return remoteDataSource.savePost(postId: postId, userId: userId);
  }

  @override
  Future<List<SavedPostEntity>> fetchSavedPosts(int userId) async {
    return await remoteDataSource.fetchSavedPosts(userId);
  }

  @override
  Future<void> deleteSavedPost(int savedPostId, {int? postId}) async {
    await remoteDataSource.deleteSavedPost(savedPostId, postId: postId);
  }

  @override
  Future<int> markPostRead(int postId) {
    return remoteDataSource.markPostRead(postId);
  }
}
