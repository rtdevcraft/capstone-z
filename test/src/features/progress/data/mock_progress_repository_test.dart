import 'package:flutter_test/flutter_test.dart';
import 'package:zenigo/src/core/models/block.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/routine_category.dart';
import 'package:zenigo/src/features/progress/data/mock_progress_repository.dart';

void main() {
  late MockProgressRepository repository;

  final testRoutine = Routine(
    id: 'test-routine',
    title: 'Test Routine',
    description: '',
    category: RoutineCategory.focusClarity,
    blocks: const [
      Block(
          id: 'b1',
          routineId: 'test-routine',
          instruction: 'Block 1',
          duration: 30,
          order: 0),
      Block(
          id: 'b2',
          routineId: 'test-routine',
          instruction: 'Block 2',
          duration: 30,
          order: 1),
    ],
  );

  setUp(() {
    repository = MockProgressRepository();
  });

  group('MockProgressRepository', () {
    group('getUserStats', () {
      test('calculates initial stats correctly from seeded data', () async {
        final stats = await repository.getUserStats();
        expect(stats.totalMinutes, 2);
        expect(stats.dailyStreak, 3);
      });

      test('returns zero stats when session history is empty', () async {
        repository.clear();
        final stats = await repository.getUserStats();
        expect(stats.totalMinutes, 0);
        expect(stats.dailyStreak, 0);
      });
    });

    group('addSession', () {
      test('increases session count in history', () async {
        final initialHistory = await repository.getSessionHistory();
        final initialCount = initialHistory.length;

        await repository.addSession(testRoutine);

        final newHistory = await repository.getSessionHistory();
        expect(newHistory.length, initialCount + 1);
        expect(newHistory.first.routineId, testRoutine.id);
      });

      test('updates totalMinutes correctly after adding a session', () async {
        final initialStats = await repository.getUserStats();
        expect(initialStats.totalMinutes, 2);

        await repository.addSession(testRoutine);

        final newStats = await repository.getUserStats();
        expect(newStats.totalMinutes, 3);
      });
    });

    group('Streak Logic', () {
      test('does not increase streak if a session for today already exists', () async {
        var stats = await repository.getUserStats();
        expect(stats.dailyStreak, 3);

        await repository.addSession(testRoutine);

        stats = await repository.getUserStats();
        expect(stats.dailyStreak, 3);
      });

      test('resets streak to 1 if the last session was more than a day ago', () async {
        repository.clear();
        
        // Add a session from 3 days ago
        await repository.addSession(
          testRoutine,
          completedAt: DateTime.now().subtract(const Duration(days: 3)),
        );

        var stats = await repository.getUserStats();
        expect(stats.dailyStreak, 0); // Streak is broken

        // Add a session for today
        await repository.addSession(testRoutine);
        stats = await repository.getUserStats();
        
        expect(stats.dailyStreak, 1);
      });
    });
  });
}