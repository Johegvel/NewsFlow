import '../entities/profile_stats_entity.dart';
import '../entities/user_preferences_entity.dart';

abstract class ProfileRepository {
  Future<ProfileStatsEntity> fetchStats();
  Future<UserPreferencesEntity> fetchPreferences();
  Future<UserPreferencesEntity> updatePreferences(
    UserPreferencesEntity preferences,
  );
  Future<void> clearReadHistory();
}
