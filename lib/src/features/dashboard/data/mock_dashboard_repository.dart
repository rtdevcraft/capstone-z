import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/user_stats.dart';
import 'package:zenigo/src/features/player/data/mock_routine_repository.dart';
import 'package:zenigo/src/features/progress/data/mock_progress_repository.dart';

/// A repository that provides mock data for the dashboard.
class MockDashboardRepository {
  MockDashboardRepository(this._routineRepository, this._progressRepository);
  final MockRoutineRepository _routineRepository;
  final MockProgressRepository _progressRepository;

  /// Fetches the featured "Daily Pick" routine.
  Future<Routine?> getDailyPick() async {
    
    return _routineRepository.getRoutineById('desk-reset');
  }

  /// Fetches the current user's stats.
  Future<UserStats> getUserStats() async {
    // Delegate to the progress repository to ensure a single source of truth.
    return _progressRepository.getUserStats();
  }
}

/// Provides an instance of the [MockDashboardRepository].
final mockDashboardRepositoryProvider = Provider<MockDashboardRepository>((ref) {
  final routineRepo = ref.watch(mockRoutineRepositoryProvider);
  final progressRepo = ref.watch(mockProgressRepositoryProvider);
  return MockDashboardRepository(routineRepo, progressRepo);
});