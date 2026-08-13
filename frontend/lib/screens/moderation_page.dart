import 'package:flutter/material.dart';

import '../models/report.dart';
import '../services/api_service.dart';

class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage> {
  final ApiService apiService = ApiService();
  late Future<List<Report>> reportsFuture;

  @override
  void initState() {
    super.initState();
    reportsFuture = apiService.fetchReports();
  }

  void reloadReports() {
    setState(() {
      reportsFuture = apiService.fetchReports();
    });
  }

  Future<void> changeStatus(Report report, String status) async {
    try {
      await apiService.updateReport(report.id, status);
      reloadReports();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte actualizado correctamente'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderación'),
        actions: [
          IconButton(
            onPressed: reloadReports,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Report>>(
        future: reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return const Center(
              child: Text('No existen reportes pendientes.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.postTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Motivo: ${report.reason}'),
                      const SizedBox(height: 4),
                      Text('Reportado por: ${report.userName}'),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: report.status,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pendiente'),
                          ),
                          DropdownMenuItem(
                            value: 'reviewed',
                            child: Text('Revisado'),
                          ),
                          DropdownMenuItem(
                            value: 'dismissed',
                            child: Text('Descartado'),
                          ),
                          DropdownMenuItem(
                            value: 'action_taken',
                            child: Text('Contenido ocultado'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null && value != report.status) {
                            changeStatus(report, value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}