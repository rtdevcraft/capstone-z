import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/user_session.dart';
import 'package:zenigo/src/core/models/user_stats.dart';

/// A repository for managing user progress, including session history and stats.
/// This mock implementation stores data in memory.
class MockProgressRepository {
  // In-memory list to store completed sessions.
  final List<UserSession> _sessions = [
    // Pre-populate with some data for a realistic-looking history.
    UserSession(
      routineId: 'morning-flow',
      routineTitle: 'Mindful Morning Flow',
      completedAt: DateTime.now().subtract(const Duration(days: 2)),
      durationInSeconds: 38,
    ),
    UserSession(
      routineId: 'desk-reset',
      routineTitle: 'Desk Worker\'s Reset',
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
      durationInSeconds: 46,
    ),
    UserSession(
      routineId: 'sleepy-stretches',
      routineTitle: 'Sleepy Stretches & Meditation',
      completedAt: DateTime.now().subtract(const Duration(hours: 4)),
      durationInSeconds: 50,
    ),
  ];

  /// Adds a new completed session to the user's history.
  Future<void> addSession(Routine routine, {DateTime? completedAt}) async {
    final session = UserSession(
      routineId: routine.id,
      routineTitle: routine.title,
      completedAt: completedAt ?? DateTime.now(),
      durationInSeconds:
          routine.blocks.fold(0, (sum, block) => sum + block.duration),
    );
    _sessions.add(session);
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate save
  }

  /// Retrieves the user's session history, sorted by most recent first.
  Future<List<UserSession>> getSessionHistory() async {
    _sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate fetch
    return _sessions;
  }

  /// Calculates and returns the user's current stats.
  Future<UserStats> getUserStats() async {
    final totalMinutes =
        _sessions.fold(0, (sum, s) => sum + s.durationInSeconds) ~/ 60;
    final streak = _calculateStreak();
    await Future.delayed(const Duration(milliseconds: 150)); // Simulate calculation
    return UserStats(dailyStreak: streak, totalMinutes: totalMinutes);
  }

  /// A helper to calculate the daily streak from session history.
  int _calculateStreak() {
    if (_sessions.isEmpty) return 0;

    // Get unique days the user completed a session, sorted descending.
    final uniqueDays = _sessions
        .map((s) => DateTime(s.completedAt.year, s.completedAt.month, s.completedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    var streak = 0;
    var today = DateTime.now();
    var todayDate = DateTime(today.year, today.month, today.day);
    var yesterdayDate = todayDate.subtract(const Duration(days: 1));

    // Check if the most recent session was today or yesterday.
    if (uniqueDays.first.isAtSameMomentAs(todayDate) ||
        uniqueDays.first.isAtSameMomentAs(yesterdayDate)) {
      streak = 1;
      for (int i = 0; i < uniqueDays.length - 1; i++) {
        final day = uniqueDays[i];
        final previousDay = uniqueDays[i + 1];
        if (day.difference(previousDay).inDays == 1) {
          streak++;
        } else {
          break; // The streak is broken.
        }
      }
    }
    return streak;
  }

  /// Clears all sessions from the in-memory list. For testing purposes.
  void clear() {
    _sessions.clear();
  }
}

/// Provides an instance of the [MockProgressRepository].
final mockProgressRepositoryProvider = Provider<MockProgressRepository>((ref) {
  return MockProgressRepository();
});