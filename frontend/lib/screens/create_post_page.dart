import 'package:flutter/material.dart';

import '../models/community.dart';
import '../services/api_service.dart';

class CreatePostPage extends StatefulWidget {
  final List<Community> communities;

  const CreatePostPage({
    super.key,
    required this.communities,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final ApiService apiService = ApiService();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  int? selectedCommunityId;
  String selectedPostType = 'discussion';
  bool saving = false;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> createPost() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty || selectedCommunityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos'),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await apiService.createPost(
        communityId: selectedCommunityId!,
        title: title,
        content: content,
        postType: selectedPostType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicación creada correctamente'),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva publicación'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedCommunityId,
                decoration: const InputDecoration(
                  labelText: 'Comunidad',
                  border: OutlineInputBorder(),
                ),
                items: widget.communities.map((community) {
                  return DropdownMenuItem<int>(
                    value: community.id,
                    child: Text(community.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCommunityId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedPostType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de contenido',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'discussion',
                    child: Text('Discusión'),
                  ),
                  DropdownMenuItem(
                    value: 'question',
                    child: Text('Pregunta'),
                  ),
                  DropdownMenuItem(
                    value: 'opinion',
                    child: Text('Opinión'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedPostType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: saving ? null : createPost,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.publish),
                label: Text(
                  saving ? 'Publicando...' : 'Publicar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}