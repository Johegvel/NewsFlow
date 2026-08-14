import 'package:flutter/material.dart';

import '../models/interest.dart';
import '../services/api_service.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final ApiService apiService = ApiService();

  List<Interest> interests = [];
  final Set<int> selectedIds = {};
  bool loading = true;
  bool saving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadInterests();
  }

  Future<void> loadInterests() async {
    try {
      final availableInterests = await apiService.fetchInterests();
      final userInterests = await apiService.fetchUserInterests();

      setState(() {
        interests = availableInterests;
        selectedIds.addAll(userInterests.map((interest) => interest.id));
        loading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        loading = false;
      });
    }
  }

  Future<void> saveInterests() async {
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un interés')),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await apiService.updateUserInterests(selectedIds.toList());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Intereses actualizados correctamente')),
        );

        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $error')));
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
        title: const Text('Mis intereses'),
        actions: [
          IconButton(
            onPressed: saving ? null : saveInterests,
            icon: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (errorMessage != null) {
            return Center(child: Text('Error: $errorMessage'));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Selecciona los temas que te interesan',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Usaremos tus intereses para ordenar el feed personalizado.',
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests.map((interest) {
                  final selected = selectedIds.contains(interest.id);

                  return FilterChip(
                    label: Text(interest.name),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          selectedIds.add(interest.id);
                        } else {
                          selectedIds.remove(interest.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: saving ? null : saveInterests,
                icon: const Icon(Icons.check),
                label: Text(saving ? 'Guardando...' : 'Guardar intereses'),
              ),
            ],
          );
        },
      ),
    );
  }
}
