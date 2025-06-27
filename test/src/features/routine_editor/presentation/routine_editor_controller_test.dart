import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/routine_category.dart';
import 'package:zenigo/src/features/player/data/routine_repository.dart';
import 'package:zenigo/src/features/routine_editor/presentation/routine_editor_controller.dart';

import 'routine_editor_controller_test.mocks.dart';

@GenerateMocks([RoutineRepository])
void main() {
  late MockRoutineRepository mockRoutineRepository;
  late RoutineEditorController controller;

  setUp(() {
    mockRoutineRepository = MockRoutineRepository();
    final container = ProviderContainer(
      overrides: [
        routineRepositoryProvider.overrideWithValue(mockRoutineRepository),
      ],
    );
    addTearDown(container.dispose);
    controller = container.read(routineEditorControllerProvider.notifier);
  });

  group('RoutineEditorController', () {
    final testRoutine = Routine(
      id: 'test-routine',
      title: 'Test Routine',
      description: 'A test routine',
      category: RoutineCategory.targetedRelief,
    );

    group('saveRoutine', () {
      test('calls repository and returns saved routine on success', () async {
        when(mockRoutineRepository.saveRoutine(testRoutine))
            .thenAnswer((_) async => testRoutine);

        final result = await controller.saveRoutine(testRoutine);

        expect(result, testRoutine);
        expect(controller.state, isA<AsyncData>());
        verify(mockRoutineRepository.saveRoutine(testRoutine)).called(1);
      });

      test('sets state to error on failure', () async {
        when(mockRoutineRepository.saveRoutine(testRoutine))
            .thenThrow(Exception('Failed to save'));

        try {
          await controller.saveRoutine(testRoutine);
        } catch (e) {
          // Exception is expected
        }

        expect(controller.state, isA<AsyncError>());
      });
    });

    group('deleteRoutine', () {
      test('calls repository on success', () async {
        when(mockRoutineRepository.deleteRoutine(testRoutine.id))
            .thenAnswer((_) async {});

        await controller.deleteRoutine(testRoutine.id);

        expect(controller.state, isA<AsyncData>());
        verify(mockRoutineRepository.deleteRoutine(testRoutine.id)).called(1);
      });

      test('sets state to error on failure', () async {
        when(mockRoutineRepository.deleteRoutine(testRoutine.id))
            .thenThrow(Exception('Failed to delete'));

        await controller.deleteRoutine(testRoutine.id);

        expect(controller.state, isA<AsyncError>());
      });
    });
  });
}