import 'post_entity.dart';

class SavedPostEntity {
  final int id;
  final int userId;
  final int postId;
  final PostEntity post;

  const SavedPostEntity({
    required this.id,
    required this.userId,
    required this.postId,
    required this.post,
  });
}
