import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenigo/src/core/models/report.dart';
import 'package:zenigo/src/features/reports/data/report_repository.dart';

class ReportController extends StateNotifier<AsyncValue<void>> {
  ReportController({required this.reportRepository})
      : super(const AsyncData(null));

  final ReportRepository reportRepository;

  Future<Report?> generateReport(DateTimeRange dateRange) async {
    state = const AsyncValue.loading();
    try {
      final report = await reportRepository.getCompletionReport(dateRange);
      state = const AsyncValue.data(null);
      return report;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final reportControllerProvider =
    StateNotifierProvider<ReportController, AsyncValue<void>>((ref) {
  return ReportController(
    reportRepository: ref.watch(reportRepositoryProvider),
  );
});
