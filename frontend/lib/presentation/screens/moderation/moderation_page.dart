import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flews_notification.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../domain/entities/report_entity.dart';
import '../../../service_locator.dart';

class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage> {
  late Future<List<ReportEntity>> reportsFuture;

  @override
  void initState() {
    super.initState();
    reloadReports();
  }

  void reloadReports() {
    setState(() {
      reportsFuture = ServiceLocator.reportRepository.fetchReports();
    });
  }

  Future<void> changeStatus(ReportEntity report, String status) async {
    try {
      await ServiceLocator.reportRepository.updateReport(report.id, status);
      reloadReports();

      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Moderación actualizada',
          message: 'El estado del reporte ha sido cambiado a: $status.',
          actionIcon: Icons.admin_panel_settings_rounded,
        );
      }
    } catch (error) {
      if (mounted) {
        FlewsNotificationHelper.show(
          context: context,
          title: 'Error de moderación',
          message: '$error',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderación de Contenido'),
        actions: [
          IconButton(
            onPressed: reloadReports,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: FutureBuilder<List<ReportEntity>>(
        future: reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.amberAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFFEF4444)),
              ),
            );
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return const Center(
              child: Text(
                'No existen reportes pendientes.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return Center(
            child: ResponsiveContainer(
              maxWidth: 850,
              child: ListView.builder(
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
                          Row(
                            children: [
                              const Icon(Icons.shield_outlined, size: 18, color: AppTheme.amberAccent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  report.postTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.darkBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Motivo: ${report.reason}',
                                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reportado por: ${report.userName}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: report.status,
                            dropdownColor: AppTheme.surfaceColor,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Estado de resolución',
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
              ),
            ),
          );
        },
      ),
    );
  }
}
