import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/routine_category.dart';
import 'package:zenigo/src/features/player/data/routine_api.dart';
import 'package:zenigo/src/features/player/data/routine_repository.dart';

import 'routine_repository_test.mocks.dart';

@GenerateMocks([RoutineApi])
void main() {
  late MockRoutineApi mockRoutineApi;
  late RoutineRepository routineRepository;

  setUp(() {
    mockRoutineApi = MockRoutineApi();
    routineRepository = RoutineRepository(mockRoutineApi);
  });

  group('RoutineRepository', () {
    final testRoutine = Routine(
      id: 'test-routine',
      title: 'Test Routine',
      description: 'A test routine',
      category: RoutineCategory.targetedRelief,
      userId: 'test-user-id',
    );

    group('getAllRoutines', () {
      test('returns routines on success', () async {
        final mockResponse = [testRoutine.toJson()];
        when(mockRoutineApi.fetchAllRoutines())
            .thenAnswer((_) async => mockResponse);

        final routines = await routineRepository.getAllRoutines();

        expect(routines, isNotEmpty);
        expect(routines.first.id, testRoutine.id);
      });

      test('throws a RoutineException on failure', () async {
        when(mockRoutineApi.fetchAllRoutines()).thenThrow(Exception());

        expect(
          () => routineRepository.getAllRoutines(),
          throwsA(isA<RoutineException>()),
        );
      });
    });

    group('getRoutineById', () {
      test('returns a routine on success', () async {
        final mockRoutineResponse = testRoutine.toJson();
        when(mockRoutineApi.fetchRoutineById(testRoutine.id))
            .thenAnswer((_) async => mockRoutineResponse);
        when(mockRoutineApi.fetchBlocksForRoutine(testRoutine.id))
            .thenAnswer((_) async => []);

        final routine = await routineRepository.getRoutineById(testRoutine.id);

        expect(routine.id, testRoutine.id);
      });

      test('throws a RoutineException on failure', () async {
        when(mockRoutineApi.fetchRoutineById(testRoutine.id))
            .thenThrow(Exception());

        expect(
          () => routineRepository.getRoutineById(testRoutine.id),
          throwsA(isA<RoutineException>()),
        );
      });
    });

    group('saveRoutine', () {
      test('returns the saved routine on success', () async {
        final mockResponse = testRoutine.toJson();
        when(mockRoutineApi.saveRoutine(any)).thenAnswer((_) async => mockResponse);
        when(mockRoutineApi.deleteBlocksForRoutine(any)).thenAnswer((_) async {});
        when(mockRoutineApi.saveBlocks(any)).thenAnswer((_) async => []);

        final routine = await routineRepository.saveRoutine(testRoutine);

        expect(routine.id, testRoutine.id);
      });

      test('throws a RoutineException on failure', () async {
        when(mockRoutineApi.saveRoutine(any)).thenThrow(Exception());

        expect(
          () => routineRepository.saveRoutine(testRoutine),
          throwsA(isA<RoutineException>()),
        );
      });
    });

    group('deleteRoutine', () {
      test('completes on success', () async {
        when(mockRoutineApi.fetchRoutineById(any))
            .thenAnswer((_) async => testRoutine.toJson());
        when(mockRoutineApi.fetchBlocksForRoutine(any))
            .thenAnswer((_) async => []);
        when(mockRoutineApi.deleteRoutine(any)).thenAnswer((_) async {});

        await routineRepository.deleteRoutine(testRoutine.id);

        verify(mockRoutineApi.deleteRoutine(testRoutine.id)).called(1);
      });

      test('throws a RoutineException on failure', () async {
        when(mockRoutineApi.fetchRoutineById(any))
            .thenAnswer((_) async => testRoutine.toJson());
        when(mockRoutineApi.fetchBlocksForRoutine(any))
            .thenAnswer((_) async => []);
        when(mockRoutineApi.deleteRoutine(any)).thenThrow(Exception());

        expect(
          () => routineRepository.deleteRoutine(testRoutine.id),
          throwsA(isA<RoutineException>()),
        );
      });
    });
  });
}