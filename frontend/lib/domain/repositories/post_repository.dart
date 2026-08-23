import '../entities/post_entity.dart';
import '../entities/comment_entity.dart';
import '../entities/saved_post_entity.dart';

abstract class PostRepository {
  Future<List<PostEntity>> fetchPosts({int? communityId, String? filter});
  Future<PostEntity> fetchPost(int postId);
  Future<PostEntity> createPost({
    required int communityId,
    required String title,
    required String content,
    required String postType,
    required int userId,
  });
  Future<List<CommentEntity>> fetchComments(int postId);
  Future<CommentEntity> createComment({
    required int postId,
    required String content,
    required int userId,
  });
  Future<int> createReaction({required int postId, required int userId});
  Future<void> deleteReaction(int reactionId);
  Future<SavedPostEntity> savePost({required int postId, required int userId});
  Future<List<SavedPostEntity>> fetchSavedPosts(int userId);
  Future<void> deleteSavedPost(int savedPostId);
  Future<int> markPostRead(int postId);
}
