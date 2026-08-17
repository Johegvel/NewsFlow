import '../../domain/entities/community_entity.dart';

class CommunityModel extends CommunityEntity {
  const CommunityModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.topic,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      topic: json['topic'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'topic': topic,
    };
  }
}
