class UserPreferencesEntity {
  final bool readingHistoryEnabled;
  final bool personalizationEnabled;
  final bool morningDigestEnabled;
  final bool curationAlertsEnabled;

  const UserPreferencesEntity({
    this.readingHistoryEnabled = true,
    this.personalizationEnabled = true,
    this.morningDigestEnabled = true,
    this.curationAlertsEnabled = true,
  });

  UserPreferencesEntity copyWith({
    bool? readingHistoryEnabled,
    bool? personalizationEnabled,
    bool? morningDigestEnabled,
    bool? curationAlertsEnabled,
  }) {
    return UserPreferencesEntity(
      readingHistoryEnabled:
          readingHistoryEnabled ?? this.readingHistoryEnabled,
      personalizationEnabled:
          personalizationEnabled ?? this.personalizationEnabled,
      morningDigestEnabled: morningDigestEnabled ?? this.morningDigestEnabled,
      curationAlertsEnabled:
          curationAlertsEnabled ?? this.curationAlertsEnabled,
    );
  }
}
