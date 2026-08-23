import '../../domain/entities/user_preferences_entity.dart';

class UserPreferencesModel extends UserPreferencesEntity {
  const UserPreferencesModel({
    required super.readingHistoryEnabled,
    required super.personalizationEnabled,
    required super.morningDigestEnabled,
    required super.curationAlertsEnabled,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      readingHistoryEnabled: json['reading_history_enabled'] != false,
      personalizationEnabled: json['personalization_enabled'] != false,
      morningDigestEnabled: json['morning_digest_enabled'] != false,
      curationAlertsEnabled: json['curation_alerts_enabled'] != false,
    );
  }
}
