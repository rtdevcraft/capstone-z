import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_io/io.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:zenigo/src/core/services/download_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zenigo/src/core/models/report.dart';
import 'package:zenigo/src/features/reports/data/report_repository.dart';
import 'package:zenigo/src/core/services/logger_service.dart';
import 'package:zenigo/src/shared/constants/app_icons.dart';

final dateRangeProvider = StateProvider<DateTimeRange>((ref) {
  return DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
});

final reportProvider = FutureProvider.autoDispose<Report>((ref) {
  final dateRange = ref.watch(dateRangeProvider);
  logger.i('reportProvider: building');
  return ref.watch(reportRepositoryProvider).getCompletionReport(dateRange);
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.download),
            onPressed: () async {
              final localizations = MaterialLocalizations.of(context);
              final report = await ref.read(reportProvider.future);
              final List<List<String>> csvDataList = [
                <String>[
                  'Routine',
                  'Completed At',
                  'Duration (minutes)'
                ],
                ...report.rows.map((row) {
                  return <String>[
                    row.routineTitle,
                    localizations.formatShortDate(row.completedAt),
                    row.duration.inMinutes.toString(),
                  ];
                })
              ];
              logger.i('CSV Data List: $csvDataList');
              final csvData = const ListToCsvConverter().convert(csvDataList);
              logger.i('CSV Data: $csvData');

              if (kIsWeb) {
                triggerWebDownload(
                    csvData, 'Mindfulness-Stretching-History.csv');
              } else {
                final directory = await getApplicationDocumentsDirectory();
                final path = '${directory.path}/report.csv';
                final file = File(path);
                await file.writeAsString(csvData);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Report saved to $path')),
                );
              }
            },
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  report.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Routine')),
                  DataColumn(label: Text('Completed At')),
                  DataColumn(label: Text('Duration')),
                ],
                rows: report.rows.map((row) {
                  return DataRow(cells: [
                    DataCell(Text(row.routineTitle)),
                    DataCell(Text(MaterialLocalizations.of(context)
                        .formatShortDate(row.completedAt))),
                    DataCell(Text('${row.duration.inMinutes} min')),
                  ]);
                }).toList(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}