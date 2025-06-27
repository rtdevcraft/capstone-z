import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:zenigo/src/core/models/report.dart';
import 'package:zenigo/src/features/reports/data/report_repository.dart';
import 'package:zenigo/src/features/reports/presentation/report_controller.dart';

import 'report_controller_test.mocks.dart';

@GenerateMocks([ReportRepository])
void main() {
  late MockReportRepository mockReportRepository;
  late ReportController controller;

  setUp(() {
    mockReportRepository = MockReportRepository();
    controller = ReportController(reportRepository: mockReportRepository);
  });

  group('ReportController', () {
    final dateRange =
        DateTimeRange(start: DateTime(2023), end: DateTime(2023, 1, 31));
    final testReport = Report(
      id: 'test-report',
      title: 'Test Report',
      dateRange: dateRange,
      rows: [],
    );

    test('generateReport returns a report on success', () async {
      when(mockReportRepository.getCompletionReport(dateRange))
          .thenAnswer((_) async => testReport);

      final report = await controller.generateReport(dateRange);

      expect(report, testReport);
      expect(controller.state, const AsyncData<void>(null));
    });

    test('generateReport returns null and sets state to error on failure',
        () async {
      when(mockReportRepository.getCompletionReport(dateRange))
          .thenThrow(Exception('Failed to generate report'));

      final report = await controller.generateReport(dateRange);

      expect(report, isNull);
      expect(controller.state, isA<AsyncError>());
    });
  });
}