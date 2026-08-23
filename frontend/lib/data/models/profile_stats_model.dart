import '../../domain/entities/profile_stats_entity.dart';

class ProfileStatsModel extends ProfileStatsEntity {
  const ProfileStatsModel({
    required super.readsCount,
    required super.critiquesCount,
    required super.savedCount,
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatsModel(
      readsCount: _asInt(json['reads_count']),
      critiquesCount: _asInt(json['critiques_count']),
      savedCount: _asInt(json['saved_count']),
    );
  }

  static int _asInt(dynamic value) {
    return value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
