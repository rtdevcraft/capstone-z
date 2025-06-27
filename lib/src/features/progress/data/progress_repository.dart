import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/features/progress/data/progress_api.dart';
import 'package:zenigo/src/features/progress/data/progress_exception.dart';
import 'package:zenigo/src/features/progress/data/supabase_progress_api.dart';
import 'package:zenigo/src/core/models/user_session.dart';
import 'package:zenigo/src/core/models/user_stats.dart';

/// A repository for managing user progress with the Supabase backend.
class ProgressRepository {
  ProgressRepository(this._api, {SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;
  final ProgressApi _api;
  final SupabaseClient _client;

  Future<void> addSession(Routine routine) async {
    try {
      final user = _client.auth.currentUser;
      log('User: $user');
      if (user == null) {
        throw const ProgressException(
            'Cannot add session for a non-authenticated user.');
      }
      final duration =
          routine.blocks.fold(0, (sum, block) => sum + block.duration);
      final sessionData = {
        'user_id': user.id,
        'routine_id': routine.id,
        'duration_secs': duration,
      };
      await _api.addSession(sessionData);
    } catch (e, st) {
      log('An unexpected error occurred when adding a session.',
          error: e, stackTrace: st);
      throw const ProgressException(
          'An unexpected error occurred. Please try again.');
    }
  }

  Future<List<UserSession>> getSessionHistory() async {
    try {
      final data = await _api.fetchSessionHistory();
      return data.map((item) {
        return UserSession(
          routineId: item['routine_id'],
          routineTitle: item['routines']['title'] ?? 'Untitled Routine',
          completedAt: DateTime.parse(item['completed_at']),
          durationInSeconds: item['duration_secs'],
        );
      }).toList();
    } catch (e, st) {
      log('An unexpected error occurred when fetching session history.',
          error: e, stackTrace: st);
      throw const ProgressException(
          'An unexpected error occurred. Please try again.');
    }
  }

  Stream<UserStats> watchUserStats() {
    return _api.watchUserProgress().map((data) {
      final history = data.map((item) {
        return UserSession(
          routineId: item['routine_id'],
          routineTitle: 'Untitled Routine',
          completedAt: DateTime.parse(item['completed_at']),
          durationInSeconds: item['duration_secs'],
        );
      }).toList();

      if (history.isEmpty) {
        return const UserStats(dailyStreak: 0, totalMinutes: 0);
      }

      final totalMinutes =
          history.fold(0, (sum, s) => sum + s.durationInSeconds) ~/ 60;
      final streak = _calculateStreak(history);

      return UserStats(dailyStreak: streak, totalMinutes: totalMinutes);
    });
  }

  Future<UserStats> getUserStats() async {
    try {
      final history = await getSessionHistory();
      if (history.isEmpty) return const UserStats(dailyStreak: 0, totalMinutes: 0);

      final totalMinutes =
          history.fold(0, (sum, s) => sum + s.durationInSeconds) ~/ 60;
      final streak = _calculateStreak(history);

      return UserStats(dailyStreak: streak, totalMinutes: totalMinutes);
    } on ProgressException {
      rethrow;
    } catch (e, st) {
      log('An unexpected error occurred when calculating user stats.',
          error: e, stackTrace: st);
      throw const ProgressException(
          'An unexpected error occurred. Please try again.');
    }
  }

  int _calculateStreak(List<UserSession> sessions) {
    if (sessions.isEmpty) return 0;

    final uniqueUtcDays = sessions.map((s) {
      final utcTime = s.completedAt.toUtc();
      return DateTime.utc(utcTime.year, utcTime.month, utcTime.day);
    }).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now().toUtc();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    final yesterdayUtc = todayUtc.subtract(const Duration(days: 1));

    final mostRecentDay = uniqueUtcDays.first;

    if (!mostRecentDay.isAtSameMomentAs(todayUtc) &&
        !mostRecentDay.isAtSameMomentAs(yesterdayUtc)) {
      return 0;
    }

    var streak = 1;
    for (int i = 0; i < uniqueUtcDays.length - 1; i++) {
      final day = uniqueUtcDays[i];
      final previousDay = uniqueUtcDays[i + 1];
      final expectedPreviousDay = day.subtract(const Duration(days: 1));

      if (previousDay.isAtSameMomentAs(expectedPreviousDay)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

final progressApiProvider = Provider<ProgressApi>((ref) {
  final client = Supabase.instance.client;
  return SupabaseProgressApi(client);
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final api = ref.watch(progressApiProvider);
  final client = Supabase.instance.client;
  return ProgressRepository(api, client: client);
});