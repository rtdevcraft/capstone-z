import 'package:flutter_test/flutter_test.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/features/player/data/mock_routine_repository.dart';

void main() {
  late MockRoutineRepository repository;

  setUp(() {
    repository = MockRoutineRepository();
  });

  group('MockRoutineRepository', () {
    group('getRoutineById', () {
      test('returns a fully populated routine for a valid ID', () async {
        final routine = await repository.getRoutineById('morning-flow');

        expect(routine, isA<Routine>());
        expect(routine.id, 'morning-flow');
        expect(routine.title, 'Mindful Morning Flow');
        expect(routine.blocks, isNotEmpty);
        expect(routine.blocks.first.instruction, 'Begin in a comfortable seated position.');
      });

      test('throws a StateError for an invalid ID', () {
        expect(
          () => repository.getRoutineById('invalid-id'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('getAllRoutines', () {
      test('returns all routines with their blocks included', () async {
        final routines = await repository.getAllRoutines();

        expect(routines, isNotEmpty);
        expect(routines.length, 4);
        // Check that a sample routine has its blocks
        final sampleRoutine = routines.firstWhere((r) => r.id == 'desk-reset');
        expect(sampleRoutine.blocks, isNotEmpty);
        expect(sampleRoutine.blocks.length, 6);
      });

      test('returns routines with blocks sorted by blockOrder', () async {
        final routines = await repository.getAllRoutines();
        final deskReset = routines.firstWhere((r) => r.id == 'desk-reset');

        // Verify that blocks are in the correct order
        for (int i = 0; i < deskReset.blocks.length; i++) {
          expect(deskReset.blocks[i].order, i);
        }
      });
    });
  });
}