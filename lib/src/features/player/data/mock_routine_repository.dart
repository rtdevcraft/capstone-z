import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenigo/src/core/models/block.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/routine_category.dart';

/// A repository that provides mock data for routines.
class MockRoutineRepository {
  /// A predefined list of sample routines.
  static final List<Routine> _routines = [
    Routine(
      id: 'morning-flow',
      title: 'Mindful Morning Flow',
      description: 'A gentle routine to start your day with awareness.',
      category: RoutineCategory.mindfulMorning,
      blocks: const [
        Block(id: 'mf-1', routineId: 'morning-flow', instruction: 'Begin in a comfortable seated position.', duration: 5, order: 0),
        Block(id: 'mf-2', routineId: 'morning-flow', instruction: 'Close your eyes and take a deep breath in.', duration: 4, order: 1),
        Block(id: 'mf-3', routineId: 'morning-flow', instruction: 'Exhale slowly, releasing all tension.', duration: 6, order: 2),
        Block(id: 'mf-4', routineId: 'morning-flow', instruction: 'Gently roll your shoulders back and down.', duration: 8, order: 3),
        Block(id: 'mf-5', routineId: 'morning-flow', instruction: 'Slowly drop your right ear to your right shoulder.', duration: 10, order: 4),
        Block(id: 'mf-6', routineId: 'morning-flow', instruction: 'Return to center and repeat on the left.', duration: 10, order: 5),
        Block(id: 'mf-7', routineId: 'morning-flow', instruction: 'Bring your awareness to the present moment.', duration: 5, order: 6),
      ],
    ),
    Routine(
      id: 'desk-reset',
      title: 'Desk Worker\'s Reset',
      description: 'Relieve tension from your neck and shoulders.',
      category: RoutineCategory.targetedRelief,
      blocks: const [
        Block(id: 'dr-1', routineId: 'desk-reset', instruction: 'Sit tall at your desk, feet flat on the floor.', duration: 5, order: 0),
        Block(id: 'dr-2', routineId: 'desk-reset', instruction: 'Interlace your fingers and push your palms away.', duration: 8, order: 1),
        Block(id: 'dr-3', routineId: 'desk-reset', instruction: 'Reach your arms overhead, palms to the ceiling.', duration: 10, order: 2),
        Block(id: 'dr-4', routineId: 'desk-reset', instruction: 'Release and gently clasp your hands behind your back.', duration: 8, order: 3),
        Block(id: 'dr-5', routineId: 'desk-reset', instruction: 'Open your chest and look slightly upward.', duration: 10, order: 4),
        Block(id: 'dr-6', routineId: 'desk-reset', instruction: 'Your short break is complete. Well done.', duration: 5, order: 5),
      ],
    ),
    Routine(
      id: 'sleepy-stretches',
      title: 'Sleepy Stretches & Meditation',
      description: 'Prepare your body and mind for a restful night\'s sleep.',
      category: RoutineCategory.eveningWindDown,
      blocks: const [
        Block(id: 'ss-1', routineId: 'sleepy-stretches', instruction: 'Lie on your back and hug your knees to your chest.', duration: 15, order: 0),
        Block(id: 'ss-2', routineId: 'sleepy-stretches', instruction: 'Gently rock side to side, massaging your lower back.', duration: 15, order: 1),
        Block(id: 'ss-3', routineId: 'sleepy-stretches', instruction: 'Release your legs and perform a full body scan.', duration: 20, order: 2),
        Block(id: 'ss-4', routineId: 'sleepy-stretches', instruction: 'Notice any areas of tension and breathe into them.', duration: 10, order: 3),
      ],
    ),
    Routine(
      id: 'midday-reset',
      title: 'Mid-day Reset',
      description: 'A quick break to refocus your energy and clarity.',
      category: RoutineCategory.focusClarity,
      blocks: const [
        Block(id: 'mr-1', routineId: 'midday-reset', instruction: 'Find a quiet space and stand tall.', duration: 5, order: 0),
        Block(id: 'mr-2', routineId: 'midday-reset', instruction: 'Perform three rounds of box breathing: in for 4, hold for 4, out for 4, hold for 4.', duration: 20, order: 1),
        Block(id: 'mr-3', routineId: 'midday-reset', instruction: 'Shake out your arms and legs.', duration: 10, order: 2),
        Block(id: 'mr-4', routineId: 'midday-reset', instruction: 'Set an intention for the rest of your day.', duration: 5, order: 3),
      ],
    ),
  ];

  /// Fetches all routines.
  Future<List<Routine>> getAllRoutines() async {
    // Simulate a network delay
    await Future.delayed(const Duration(milliseconds: 400));
    return _routines;
  }

  /// Fetches a routine by its unique ID.
  Future<Routine> getRoutineById(String id) async {
    // Simulate a network delay
    await Future.delayed(const Duration(milliseconds: 200));
    // firstWhere throws a StateError if no element is found, which mimics
    // the behavior of the real repository throwing an exception.
    return _routines.firstWhere((routine) => routine.id == id);
  }
/// Saves a routine (creates or updates) and its blocks.
  Future<Routine> saveRoutine(Routine routine) async {
    // Simulate a network delay
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _routines.indexWhere((r) => r.id == routine.id);
    if (index != -1) {
      // Update existing routine
      _routines[index] = routine;
      return routine;
    } else {
      // Add new routine
      final newRoutine = routine.copyWith(id: 'new-routine-${DateTime.now().millisecondsSinceEpoch}');
      _routines.add(newRoutine);
      return newRoutine;
    }
  }
}

/// Provides an instance of the [MockRoutineRepository].
final mockRoutineRepositoryProvider = Provider<MockRoutineRepository>((ref) {
  return MockRoutineRepository();
});