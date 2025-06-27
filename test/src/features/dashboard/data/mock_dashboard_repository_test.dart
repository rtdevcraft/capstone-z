import 'package:flutter_test/flutter_test.dart';
import 'package:zenigo/src/features/dashboard/data/mock_dashboard_repository.dart';
import 'package:zenigo/src/features/player/data/mock_routine_repository.dart';
import 'package:zenigo/src/features/progress/data/mock_progress_repository.dart';

void main() {
  late MockDashboardRepository repository;
  late MockRoutineRepository mockRoutineRepository;
  late MockProgressRepository mockProgressRepository;

  setUp(() {
    mockRoutineRepository = MockRoutineRepository();
    mockProgressRepository = MockProgressRepository();
    repository = MockDashboardRepository(
      mockRoutineRepository,
      mockProgressRepository,
    );
  });

  group('MockDashboardRepository', () {
    test('getDailyPick returns the correct routine from the routine repository', () async {
      final routine = await repository.getDailyPick();
      
      // The mock dashboard is hardcoded to return 'desk-reset'
      expect(routine, isNotNull);
      expect(routine!.id, 'desk-reset');
    });

    test('getUserStats returns the stats from the progress repository', () async {
      final stats = await repository.getUserStats();
      final expectedStats = await mockProgressRepository.getUserStats();

      // Verifies that the dashboard repo is just a passthrough for stats
      expect(stats, isNotNull);
      expect(stats.dailyStreak, expectedStats.dailyStreak);
      expect(stats.totalMinutes, expectedStats.totalMinutes);
    });
  });
}