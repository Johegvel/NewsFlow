class ProfileStatsEntity {
  final int readsCount;
  final int critiquesCount;
  final int savedCount;
  final int commentsCount;

  const ProfileStatsEntity({
    this.readsCount = 0,
    this.critiquesCount = 0,
    this.savedCount = 0,
    this.commentsCount = 0,
  });
}