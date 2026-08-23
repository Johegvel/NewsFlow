import '../../domain/entities/profile_stats_entity.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/remote_api_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final RemoteApiDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileStatsEntity> fetchStats() =>
      remoteDataSource.fetchProfileStats();

  @override
  Future<UserPreferencesEntity> fetchPreferences() =>
      remoteDataSource.fetchPreferences();

  @override
  Future<UserPreferencesEntity> updatePreferences(
    UserPreferencesEntity preferences,
  ) => remoteDataSource.updatePreferences(preferences);

  @override
  Future<void> clearReadHistory() => remoteDataSource.clearReadHistory();
}
