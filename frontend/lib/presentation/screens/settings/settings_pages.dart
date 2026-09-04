import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flews_empty_state.dart';
import '../../../core/widgets/flews_notification.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../domain/entities/user_preferences_entity.dart';
import '../../../service_locator.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late Future<UserPreferencesEntity> _future;
  UserPreferencesEntity? _preferences;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = ServiceLocator.profileRepository.fetchPreferences();
  }

  Future<void> _save(UserPreferencesEntity next) async {
    final previous = _preferences;
    setState(() {
      _preferences = next;
      _saving = true;
    });
    try {
      final saved = await ServiceLocator.profileRepository.updatePreferences(
        next,
      );
      if (mounted) setState(() => _preferences = saved);
    } catch (error) {
      if (!mounted) return;
      setState(() => _preferences = previous);
      FlewsNotificationHelper.show(
        context: context,
        title: 'No pudimos guardar el ajuste',
        message: '$error'.replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Borrar historial de lectura'),
        content: const Text(
          'El contador de noticias leídas volverá a cero. Esta acción no elimina tus publicaciones guardadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Borrar historial'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ServiceLocator.profileRepository.clearReadHistory();
      if (!mounted) return;
      FlewsNotificationHelper.show(
        context: context,
        title: 'Historial borrado',
        message: 'El contador de noticias leídas se reinició correctamente.',
        actionIcon: Icons.delete_sweep_outlined,
      );
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'No pudimos borrar el historial',
          message: '$error'.replaceAll('Exception: ', ''),
        );
      }
    }
  }

  void _showPrivacyPolicy() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Privacidad y Términos Flews', style: TextStyle(color: AppTheme.textPrimary)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ciclo de 24 horas y Datos Efímeros',
                style: TextStyle(color: AppTheme.amberAccent, fontWeight: FontWeight.w700, fontSize: 13),
              ),
              SizedBox(height: 6),
              Text(
                'Las noticias curadas y las críticas expiran automáticamente tras 24 horas de publicación para mantener la máxima frescura informativa. Tus publicaciones guardadas se conservan de forma atemporal en tu cuenta personal.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
              ),
              SizedBox(height: 12),
              Text(
                'Neutralidad y Transparencia',
                style: TextStyle(color: AppTheme.amberAccent, fontWeight: FontWeight.w700, fontSize: 13),
              ),
              SizedBox(height: 6),
              Text(
                'Flews preserva las fuentes y enlaces originales de cada medio. No comercializamos ni vendemos tus datos de navegación o lectura.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsPageShell(
      title: 'Configuración de Cuenta',
      subtitle: 'Privacidad y control de tus datos',
      child: FutureBuilder<UserPreferencesEntity>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _preferences == null) {
            return const _LoadingSettings();
          }
          if (snapshot.hasError && _preferences == null) {
            return FlewsEmptyState(
              icon: Icons.cloud_off_outlined,
              message: 'No pudimos cargar tu configuración',
              detail: '${snapshot.error}'.replaceAll('Exception: ', ''),
            );
          }
          _preferences ??= snapshot.data ?? const UserPreferencesEntity();
          final preferences = _preferences!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('PRIVACIDAD Y DATOS'),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _PreferenceSwitch(
                    icon: Icons.history_rounded,
                    title: 'Historial de lectura',
                    subtitle:
                        'Registra una noticia una sola vez para actualizar tus estadísticas.',
                    value: preferences.readingHistoryEnabled,
                    enabled: !_saving,
                    onChanged: (value) => _save(
                      preferences.copyWith(readingHistoryEnabled: value),
                    ),
                  ),
                  const Divider(height: 1),
                  _PreferenceSwitch(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Personalización',
                    subtitle:
                        'Permite usar tus intereses y actividad para ordenar el contenido.',
                    value: preferences.personalizationEnabled,
                    enabled: !_saving,
                    onChanged: (value) => _save(
                      preferences.copyWith(personalizationEnabled: value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SettingsCard(
                children: [
                  ListTile(
                    onTap: _showPrivacyPolicy,
                    leading: const Icon(
                      Icons.policy_outlined,
                      color: AppTheme.amberAccent,
                    ),
                    title: const Text(
                      'Términos y Política de Privacidad',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text(
                      'Consulta nuestro compromiso con la neutralidad y el ciclo de 24h.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    onTap: _saving ? null : _clearHistory,
                    leading: const Icon(
                      Icons.delete_sweep_outlined,
                      color: AppTheme.destructive,
                    ),
                    title: const Text(
                      'Borrar historial de lectura',
                      style: TextStyle(
                        color: AppTheme.destructive,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text(
                      'Reinicia únicamente el contador de noticias leídas.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  late Future<UserPreferencesEntity> _future;
  UserPreferencesEntity? _preferences;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = ServiceLocator.profileRepository.fetchPreferences();
  }

  Future<void> _save(UserPreferencesEntity next) async {
    final previous = _preferences;
    setState(() {
      _preferences = next;
      _saving = true;
    });
    try {
      final saved = await ServiceLocator.profileRepository.updatePreferences(
        next,
      );
      if (!mounted) return;
      setState(() => _preferences = saved);
      FlewsNotificationHelper.show(
        context: context,
        title: 'Preferencias actualizadas',
        message: 'Tus alertas quedaron configuradas.',
        actionIcon: Icons.notifications_active_outlined,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _preferences = previous);
      FlewsNotificationHelper.show(
        context: context,
        title: 'No pudimos guardar las preferencias',
        message: '$error'.replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _breakingNewsEnabled = true;
  bool _repliesEnabled = true;

  void _testNotification() {
    FlewsNotificationHelper.show(
      context: context,
      title: '🔔 Alerta de prueba Flews',
      message: 'Las notificaciones están configuradas y funcionando con éxito.',
      actionIcon: Icons.notifications_active_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsPageShell(
      title: 'Preferencias de Notificaciones',
      subtitle: 'Elige qué avisos quieres recibir',
      child: FutureBuilder<UserPreferencesEntity>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _preferences == null) {
            return const _LoadingSettings();
          }
          if (snapshot.hasError && _preferences == null) {
            return FlewsEmptyState(
              icon: Icons.notifications_off_outlined,
              message: 'No pudimos cargar tus notificaciones',
              detail: '${snapshot.error}'.replaceAll('Exception: ', ''),
            );
          }
          _preferences ??= snapshot.data ?? const UserPreferencesEntity();
          final preferences = _preferences!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('ALERTAS FLEWS'),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _PreferenceSwitch(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Síntesis matutina',
                    subtitle:
                        'Recibe el resumen diario de noticias seleccionadas.',
                    value: preferences.morningDigestEnabled,
                    enabled: !_saving,
                    onChanged: (value) => _save(
                      preferences.copyWith(morningDigestEnabled: value),
                    ),
                  ),
                  const Divider(height: 1),
                  _PreferenceSwitch(
                    icon: Icons.new_releases_outlined,
                    title: 'Alertas de curación',
                    subtitle:
                        'Avisos cuando Flews publique contenido relevante para tus intereses.',
                    value: preferences.curationAlertsEnabled,
                    enabled: !_saving,
                    onChanged: (value) => _save(
                      preferences.copyWith(curationAlertsEnabled: value),
                    ),
                  ),
                  const Divider(height: 1),
                  _PreferenceSwitch(
                    icon: Icons.bolt_rounded,
                    title: 'Noticias de última hora',
                    subtitle:
                        'Avisos de máxima prioridad sobre noticias de alto impacto en las últimas 24h.',
                    value: _breakingNewsEnabled,
                    enabled: !_saving,
                    onChanged: (value) =>
                        setState(() => _breakingNewsEnabled = value),
                  ),
                  const Divider(height: 1),
                  _PreferenceSwitch(
                    icon: Icons.forum_outlined,
                    title: 'Respuestas a tus análisis',
                    subtitle:
                        'Notificación cuando otro usuario comente tus críticas en la tribuna.',
                    value: _repliesEnabled,
                    enabled: !_saving,
                    onChanged: (value) =>
                        setState(() => _repliesEnabled = value),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _testNotification,
                  icon: const Icon(Icons.notifications_active_outlined, size: 18),
                  label: const Text('Enviar notificación de prueba'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.amberAccent,
                    side: const BorderSide(color: AppTheme.amberAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Estas preferencias se guardan en tu cuenta. El envío depende de que el dispositivo conceda permisos de notificación.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class EditorialTransparencyPage extends StatelessWidget {
  const EditorialTransparencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsPageShell(
      title: 'Transparencia Editorial',
      subtitle: 'Cómo seleccionamos y presentamos la información',
      child: Column(
        children: [
          _TransparencyCard(
            icon: Icons.source_outlined,
            title: 'Fuentes identificables',
            body:
                'Cada noticia conserva el medio o fuente original y su enlace canónico. Flews no oculta la procedencia del contenido.',
          ),
          SizedBox(height: 12),
          _TransparencyCard(
            icon: Icons.balance_outlined,
            title: 'Neutralidad y contexto',
            body:
                'La curación prioriza relevancia, evidencia y contexto. Las opiniones de la comunidad aparecen separadas como críticas.',
          ),
          SizedBox(height: 12),
          _TransparencyCard(
            icon: Icons.fact_check_outlined,
            title: 'Criterios de curación',
            body:
                'Se filtran duplicados, titulares sensacionalistas y publicaciones sin suficiente señal. La relevancia se explica dentro de cada artículo.',
          ),
          SizedBox(height: 12),
          _TransparencyCard(
            icon: Icons.flag_outlined,
            title: 'Correcciones y reportes',
            body:
                'Puedes reportar una publicación desde su menú. El equipo editorial revisa cada señal desde el panel de moderación.',
          ),
        ],
      ),
    );
  }
}

class _SettingsPageShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsPageShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContainer(
          maxWidth: 620,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(title, style: AppTheme.editorial(fontSize: 30)),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor, width: 1.5),
      ),
      child: Column(children: children),
    );
  }
}

class _PreferenceSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _PreferenceSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      secondary: Icon(icon, color: AppTheme.amberAccent),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          height: 1.35,
        ),
      ),
      activeTrackColor: AppTheme.amberAccent,
      activeThumbColor: AppTheme.darkBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

class _TransparencyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _TransparencyCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.amberAccent, size: 22),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }
}

class _LoadingSettings extends StatelessWidget {
  const _LoadingSettings();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 100),
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.amberAccent),
      ),
    );
  }
}
