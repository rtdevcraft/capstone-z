import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:zenigo/src/core/models/report.dart';
import 'package:zenigo/src/core/services/logger_service.dart';

class ReportRepository {
  ReportRepository(this._client);
  final SupabaseClient _client;

  Future<Report> getCompletionReport(DateTimeRange dateRange) async {
    logger.i('ReportRepository: getCompletionReport started');
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      logger.w('ReportRepository: user not authenticated');
      throw Exception('User not authenticated');
    }

    final from = dateRange.start;
    final to = dateRange.end;
    logger.i('ReportRepository: date range: $from - $to');
    final data = await _client
        .from('user_progress')
        .select('*, routines(title)')
        .eq('user_id', userId)
        .gte('completed_at', from.toUtc().toIso8601String())
        .lte('completed_at', to.toUtc().toIso8601String());

    logger.i('ReportRepository: fetched data: $data');

    final rows = data
        .map((item) => UserSessionRow(
              routineTitle: item['routines']?['title'] ?? 'Untitled Routine',
              completedAt: DateTime.parse(item['completed_at']),
              duration: Duration(seconds: item['duration_secs']),
            ))
        .toList();
    logger.i('ReportRepository: processed rows: $rows');

    return Report(
      id: const Uuid().v4(),
      title: 'Routine Completion Report',
      dateRange: dateRange,
      rows: rows,
    );
  }
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final client = Supabase.instance.client;
  return ReportRepository(client);
});