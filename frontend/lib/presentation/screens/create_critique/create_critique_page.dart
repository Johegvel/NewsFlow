import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/post_formatters.dart';
import '../../../core/widgets/flews_notification.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../service_locator.dart';

class CreateCritiquePage extends StatefulWidget {
  final PostEntity quotedPost;

  const CreateCritiquePage({super.key, required this.quotedPost});

  @override
  State<CreateCritiquePage> createState() => _CreateCritiquePageState();
}

class _CreateCritiquePageState extends State<CreateCritiquePage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String selectedStance = 'Análisis Técnico';
  bool saving = false;

  static const stances = [
    'Análisis Técnico',
    'Crítica Constructiva',
    'Impacto Social / Ético',
    'Perspectiva Contraria',
    'Reflexión / Aprendizaje',
  ];

  int get currentUserId => ServiceLocator.authRepository.currentUser?.id ?? 1;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> submitCritique() async {
    final title = titleController.text.trim();
    final body = contentController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      FlewsNotificationHelper.show(
        context: context,
        title: 'Completa tu análisis',
        message:
            'Añade un titular y desarrolla tus argumentos antes de publicar.',
        actionIcon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => saving = true);
    try {
      final formattedContent =
          '''
[$selectedStance]
$body

────────────────────────────
📌 Noticia Citada: "${widget.quotedPost.title}"
🔗 ID Noticia: ${widget.quotedPost.id}
🏛️ Comunidad: ${widget.quotedPost.communityName}
'''
              .trim();

      await ServiceLocator.postRepository.createPost(
        communityId: widget.quotedPost.communityId,
        title: title,
        content: formattedContent,
        postType: 'critique',
        userId: currentUserId,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'No pudimos publicar tu crítica',
          message: '$error'.replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quoted = widget.quotedPost;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Escribir Crítica',
          style: AppTheme.editorial(fontSize: 28),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '📌 NOTICIA CITADA',
                        style: TextStyle(
                          color: AppTheme.amberAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${communityEmoji(quoted.communitySlug, quoted.communityName)} ${quoted.communityName}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quoted.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.editorial(fontSize: 18, height: 1.15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _FieldLabel('ENFOQUE / POSTURA'),
            const SizedBox(height: 7),
            DropdownButtonFormField<String>(
              initialValue: selectedStance,
              dropdownColor: AppTheme.surfaceColor,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textSecondary,
              ),
              items: stances
                  .map(
                    (stance) =>
                        DropdownMenuItem(value: stance, child: Text(stance)),
                  )
                  .toList(),
              onChanged: saving
                  ? null
                  : (value) {
                      if (value != null) setState(() => selectedStance = value);
                    },
            ),
            const SizedBox(height: 18),
            const _FieldLabel('TITULAR DE TU ANÁLISIS'),
            const SizedBox(height: 7),
            TextField(
              controller: titleController,
              enabled: !saving,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Una idea clara que invite a leer...',
              ),
            ),
            const SizedBox(height: 18),
            const _FieldLabel('DESARROLLA TU CRÍTICA'),
            const SizedBox(height: 7),
            TextField(
              controller: contentController,
              enabled: !saving,
              minLines: 8,
              maxLines: 12,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText:
                    'Expón argumentos, evidencia, contexto y una conclusión constructiva...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const ValueKey('publish-critique-button'),
              onPressed: saving ? null : submitCritique,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.darkBackground,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: const Text('Publicar Crítica en la Tribuna'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Al publicar aceptas mantener una conversación respetuosa y basada en argumentos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }
}
