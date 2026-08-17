import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flews_notification.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../service_locator.dart';

class CreateCritiquePage extends StatefulWidget {
  final PostEntity quotedPost;

  const CreateCritiquePage({
    super.key,
    required this.quotedPost,
  });

  @override
  State<CreateCritiquePage> createState() => _CreateCritiquePageState();
}

class _CreateCritiquePageState extends State<CreateCritiquePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  String selectedStance = 'Análisis Técnico';
  bool saving = false;

  final List<String> stances = [
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
        title: 'Campos requeridos',
        message: 'Por favor añade un titular y redacta tu análisis editorial.',
        actionIcon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      // Estructurar el contenido citando formalmente la noticia original
      final formattedContent = '''
[$selectedStance]
$body

────────────────────────────
📌 Noticia Citada: "${widget.quotedPost.title}"
🏛️ Comunidad: ${widget.quotedPost.communityName}
'''.trim();

      await ServiceLocator.postRepository.createPost(
        communityId: widget.quotedPost.communityId,
        title: title,
        content: formattedContent,
        postType: 'critique',
        userId: currentUserId,
      );

      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: '¡Crítica publicada!',
          message: 'Tu análisis ha sido compartido en la sección de Críticas.',
          actionIcon: Icons.rate_review_outlined,
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Error al publicar crítica',
          message: '$error',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quoted = widget.quotedPost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escribir Crítica Editorial'),
      ),
      body: Center(
        child: ResponsiveContainer(
          maxWidth: 720,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Quoted News Card Preview (Like quoting a story)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.amberAccent.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.format_quote_rounded, color: AppTheme.amberAccent, size: 20),
                        const SizedBox(width: 6),
                        const Text(
                          'NOTICIA CITADA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppTheme.amberAccent,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.darkBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            quoted.communityName,
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quoted.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quoted.content,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Editorial Stance Selector
              DropdownButtonFormField<String>(
                initialValue: selectedStance,
                dropdownColor: AppTheme.surfaceColor,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Enfoque / Postura del Análisis',
                  prefixIcon: Icon(Icons.psychology_alt_outlined, color: AppTheme.amberAccent),
                ),
                items: stances.map((stance) {
                  return DropdownMenuItem(
                    value: stance,
                    child: Text(stance),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStance = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Critique Headline
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Titular de tu análisis o crítica',
                  hintText: 'ej. Por qué este avance cambia el paradigma...',
                  prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.amberAccent),
                ),
              ),
              const SizedBox(height: 16),

              // Critique Body
              TextField(
                controller: contentController,
                maxLines: 7,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Cuerpo del análisis detallado',
                  alignLabelWithHint: true,
                  hintText: 'Expresa tus argumentos, datos, contexto o discrepancias con profundidad...',
                ),
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: saving ? null : submitCritique,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'Publicar Crítica en la Tribuna',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.amberAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
