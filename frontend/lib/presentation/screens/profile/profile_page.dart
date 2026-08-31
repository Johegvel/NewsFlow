import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/post_formatters.dart';
import '../../../core/widgets/flews_bottom_navigation.dart';
import '../../../core/widgets/flews_notification.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../domain/entities/profile_stats_entity.dart';
import '../../../service_locator.dart';
import '../auth/auth_screen.dart';
import '../home/home_page.dart';
import '../moderation/moderation_page.dart';
import '../saved_posts/saved_posts_page.dart';
import '../settings/settings_pages.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<ProfileStatsEntity> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<ProfileStatsEntity> _loadStats() async {
    return ServiceLocator.profileRepository.fetchStats();
  }

  Future<void> _openSettings(Widget page) async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) setState(() => _statsFuture = _loadStats());
  }

  void _openTopLevel(Widget page) {
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (_) => page),
      (_) => false,
    );
  }

  void _onBottomSelected(int index) {
    if (index == 0) _openTopLevel(const HomePage());
    if (index == 1) _openTopLevel(const HomePage(initialTab: 1));
    if (index == 2) _openTopLevel(const SavedPostsPage());
  }

  Future<void> _logout() async {
    await ServiceLocator.authRepository.logout();
    if (!mounted) return;
    FlewsNotificationHelper.show(
      context: context,
      title: 'Sesión finalizada',
      message: 'Has cerrado sesión correctamente.',
    );
    _openTopLevel(const AuthScreen());
  }

@override
Widget build(BuildContext context) {
  final user = ServiceLocator.authRepository.currentUser;
  final displayName = user?.name ?? 'Usuario Flews';

  return Scaffold(
    bottomNavigationBar: FlewsBottomNavigation(
      selectedIndex: 3,
      onSelected: _onBottomSelected,
    ),
    body: SafeArea(
      bottom: false,
      child: ResponsiveContainer(
        maxWidth: 600,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Mi Perfil',
                    style: AppTheme.editorial(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.amberAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'EDITOR FLEWS',
                    style: TextStyle(
                      color: AppTheme.amberAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.amberAccent,
                    child: Text(
                      initialsFor(displayName),
                      style: const TextStyle(
                        color: AppTheme.darkBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    color: AppTheme.textSecondary,
                    size: 19,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            FutureBuilder<ProfileStatsEntity>(
              future: _statsFuture,
              builder: (context, snapshot) {
                final stats =
                    snapshot.data ?? const ProfileStatsEntity();

                final isLoading =
                    snapshot.connectionState ==
                    ConnectionState.waiting;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: isLoading
                                ? '…'
                                : '${stats.readsCount}',
                            label: 'Noticias\nleídas',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            value: isLoading
                                ? '…'
                                : '${stats.critiquesCount}',
                            label: 'Críticas\npublicadas',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: isLoading
                                ? '…'
                                : '${stats.savedCount}',
                            label: 'Noticias\nguardadas',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            value: isLoading
                                ? '…'
                                : '${stats.commentsCount}',
                            label: 'Comentarios\nescritos',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 26),

            const Text(
              'CONFIGURACIÓN',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            Material(
              color: AppTheme.surfaceColor,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: AppTheme.borderColor,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    emoji: '⚙️',
                    title: 'Configuración de Cuenta',
                    subtitle: 'Ajustes de privacidad y datos',
                    onTap: () =>
                        _openSettings(const AccountSettingsPage()),
                  ),
                  const Divider(height: 1),
                  _SettingsRow(
                    emoji: '🔔',
                    title: 'Preferencias de Notificaciones',
                    subtitle: 'Alertas matutinas y de curación',
                    onTap: () => _openSettings(
                      const NotificationPreferencesPage(),
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsRow(
                    emoji: '🛡️',
                    title: 'Transparencia Editorial',
                    subtitle: 'Nuestras fuentes y neutralidad',
                    onTap: () => _openSettings(
                      const EditorialTransparencyPage(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            const Text(
              'HERRAMIENTAS EDITORIALES',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            Material(
              color: AppTheme.surfaceColor,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: AppTheme.borderColor,
                  width: 1.5,
                ),
              ),
              child: _SettingsRow(
                emoji: '🧰',
                title: 'Panel de moderación',
                subtitle: 'Revisar reportes de la comunidad',
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const ModerationPage(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(
                Icons.logout_rounded,
                color: AppTheme.destructive,
              ),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: AppTheme.destructive,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppTheme.destructive,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}


class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.editorial(
              fontSize: 25,
              color: AppTheme.amberAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text(emoji, style: const TextStyle(fontSize: 20)),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.textSecondary,
        size: 24,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}
